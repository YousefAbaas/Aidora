"""Adversarial tests for the synthetic hash-chained audit log."""
import copy
import unittest

from audit_log import append_event, verify_log


class SyntheticAuditLogTests(unittest.TestCase):
    def setUp(self):
        self.evaluation = {
            "decision": "ALLOW",
            "policy_id": "synthetic-api-policy",
            "policy_version": "1",
            "reason_codes": ["all_explicit_conditions_satisfied"],
        }
        self.log = []
        append_event(self.log, self.evaluation, evaluated_at="2027-06-01T12:00:00Z")
        append_event(
            self.log,
            {**self.evaluation, "decision": "REVIEW", "reason_codes": ["manual_review_required"]},
            evaluated_at="2027-06-01T12:05:00Z",
        )

    def test_valid_chain_verifies(self):
        self.assertTrue(verify_log(self.log)["valid"])
        self.assertEqual(verify_log(self.log)["checked_events"], 2)

    def test_decision_tampering_is_detected(self):
        changed = copy.deepcopy(self.log)
        changed[0]["decision"] = "DENY"
        self.assertEqual(verify_log(changed)["reason"], "event_hash_mismatch")

    def test_middle_event_deletion_is_detected(self):
        changed = copy.deepcopy(self.log)
        del changed[0]
        self.assertEqual(verify_log(changed)["reason"], "sequence_mismatch")

    def test_event_reordering_is_detected(self):
        changed = copy.deepcopy(self.log)
        changed.reverse()
        self.assertEqual(verify_log(changed)["reason"], "sequence_mismatch")

    def test_previous_hash_tampering_is_detected(self):
        changed = copy.deepcopy(self.log)
        changed[1]["previous_hash"] = "f" * 64
        self.assertEqual(verify_log(changed)["reason"], "previous_hash_mismatch")

    def test_event_hash_tampering_is_detected(self):
        changed = copy.deepcopy(self.log)
        changed[1]["event_hash"] = "0" * 64
        self.assertEqual(verify_log(changed)["reason"], "event_hash_mismatch")

    def test_malformed_timestamp_is_rejected_when_appending(self):
        with self.assertRaises(ValueError):
            append_event([], self.evaluation, evaluated_at="2027-06-01T12:00:00")

    def test_missing_reason_is_rejected_when_appending(self):
        with self.assertRaises(ValueError):
            append_event([], {**self.evaluation, "reason_codes": []}, evaluated_at="2027-06-01T12:00:00Z")

    def test_final_event_truncation_requires_external_checkpoint(self):
        prefix = copy.deepcopy(self.log[:1])
        self.assertTrue(verify_log(prefix)["valid"])

    def test_append_refuses_tampered_existing_chain(self):
        changed = copy.deepcopy(self.log)
        changed[0]["decision"] = "DENY"
        with self.assertRaisesRegex(ValueError, "invalid audit log"):
            append_event(changed, self.evaluation, evaluated_at="2027-06-01T12:10:00Z")

    def test_append_refuses_deleted_middle_event(self):
        changed = copy.deepcopy(self.log)
        del changed[0]
        with self.assertRaisesRegex(ValueError, "invalid audit log"):
            append_event(changed, self.evaluation, evaluated_at="2027-06-01T12:10:00Z")

    def test_verifier_rejects_empty_reason_codes(self):
        changed = copy.deepcopy(self.log)
        changed[0]["reason_codes"] = []
        # Re-hash to isolate schema validation from hash validation.
        import audit_log
        unsigned = {key: value for key, value in changed[0].items() if key != "event_hash"}
        changed[0]["event_hash"] = audit_log._event_hash(unsigned)
        self.assertEqual(verify_log(changed)["reason"], "reason_codes_invalid")

    def test_verifier_rejects_boolean_sequence(self):
        changed = copy.deepcopy(self.log)
        changed[0]["sequence"] = True
        self.assertEqual(verify_log(changed)["reason"], "sequence_mismatch")


if __name__ == "__main__":
    unittest.main()
