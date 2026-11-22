import unittest
from datetime import datetime, timezone

from policy_check import evaluate_policy


NOW = datetime(2027, 3, 1, tzinfo=timezone.utc)


def valid_policy():
    return {
        "policy_id": "synthetic-policy-001",
        "version": "0.1",
        "status": "active",
        "effective_from": "2027-01-01T00:00:00+00:00",
        "expires_at": "2027-12-31T23:59:59+00:00",
        "allowed_purposes": ["synthetic_method_validation"],
        "denied_purposes": ["commercial_model_training"],
        "allowed_actions": ["run_aggregate_test"],
        "denied_actions": ["export_row_level_data"],
        "required_approvals": ["community_governance", "data_steward"],
        "required_context": {"environment": "approved_sandbox"},
        "review_required": False,
    }


def valid_request():
    return {
        "purpose": "synthetic_method_validation",
        "action": "run_aggregate_test",
        "approvals": [
            {"type": "community_governance", "status": "approved", "reference": "fake-a"},
            {"type": "data_steward", "status": "approved", "reference": "fake-b"},
        ],
        "context": {"environment": "approved_sandbox"},
    }


class PolicyCheckTests(unittest.TestCase):
    def evaluate(self, policy=None, request=None, now=NOW):
        return evaluate_policy(
            policy if policy is not None else valid_policy(),
            request if request is not None else valid_request(),
            now=now,
        )

    def test_all_explicit_conditions_allow(self):
        result = self.evaluate()
        self.assertEqual(result["decision"], "ALLOW")
        self.assertEqual(result["reason_codes"], ["all_explicit_conditions_satisfied"])

    def test_explicitly_denied_purpose_denies(self):
        request = valid_request()
        request["purpose"] = "commercial_model_training"
        self.assertEqual(self.evaluate(request=request)["decision"], "DENY")

    def test_unlisted_purpose_does_not_allow(self):
        request = valid_request()
        request["purpose"] = "unspecified_future_research"
        self.assertEqual(self.evaluate(request=request)["decision"], "DENY")

    def test_explicitly_denied_action_denies(self):
        request = valid_request()
        request["action"] = "export_row_level_data"
        self.assertEqual(self.evaluate(request=request)["decision"], "DENY")

    def test_missing_approval_requires_review(self):
        request = valid_request()
        request["approvals"] = request["approvals"][:1]
        self.assertEqual(self.evaluate(request=request)["decision"], "REVIEW")

    def test_rejected_approval_denies(self):
        request = valid_request()
        request["approvals"][0]["status"] = "rejected"
        self.assertEqual(self.evaluate(request=request)["decision"], "DENY")

    def test_expired_policy_denies(self):
        policy = valid_policy()
        policy["expires_at"] = "2027-02-01T00:00:00+00:00"
        self.assertEqual(self.evaluate(policy=policy)["decision"], "DENY")

    def test_revoked_policy_denies(self):
        policy = valid_policy()
        policy["status"] = "revoked"
        self.assertEqual(self.evaluate(policy=policy)["decision"], "DENY")

    def test_missing_context_requires_review(self):
        request = valid_request()
        request["context"] = {}
        self.assertEqual(self.evaluate(request=request)["decision"], "REVIEW")

    def test_context_condition_mismatch_denies(self):
        request = valid_request()
        request["context"]["environment"] = "unapproved_workspace"
        self.assertEqual(self.evaluate(request=request)["decision"], "DENY")

    def test_policy_can_force_human_review(self):
        policy = valid_policy()
        policy["review_required"] = True
        self.assertEqual(self.evaluate(policy=policy)["decision"], "REVIEW")

    def test_naive_evaluation_time_never_allows(self):
        naive = datetime(2027, 3, 1)
        self.assertEqual(self.evaluate(now=naive)["decision"], "REVIEW")

    def test_missing_required_policy_field_never_allows(self):
        policy = valid_policy()
        del policy["required_context"]
        self.assertEqual(self.evaluate(policy=policy)["decision"], "REVIEW")

    def test_invalid_policy_timestamp_requires_review(self):
        policy = valid_policy()
        policy["effective_from"] = "not-a-timestamp"
        self.assertEqual(self.evaluate(policy=policy)["decision"], "REVIEW")

    def test_invalid_review_flag_requires_review(self):
        policy = valid_policy()
        policy["review_required"] = "false"
        self.assertEqual(self.evaluate(policy=policy)["decision"], "REVIEW")

    def test_unrecognised_approval_status_requires_review(self):
        request = valid_request()
        request["approvals"][0]["status"] = "maybe"
        self.assertEqual(self.evaluate(request=request)["decision"], "REVIEW")

    def test_unlisted_action_does_not_allow(self):
        request = valid_request()
        request["action"] = "copy_dataset"
        self.assertEqual(self.evaluate(request=request)["decision"], "DENY")

    def test_policy_not_yet_effective_requires_review(self):
        policy = valid_policy()
        policy["effective_from"] = "2027-04-01T00:00:00+00:00"
        self.assertEqual(self.evaluate(policy=policy)["decision"], "REVIEW")

    def test_draft_policy_requires_review(self):
        policy = valid_policy()
        policy["status"] = "draft"
        self.assertEqual(self.evaluate(policy=policy)["decision"], "REVIEW")

    def test_missing_request_purpose_requires_review(self):
        request = valid_request()
        del request["purpose"]
        self.assertEqual(self.evaluate(request=request)["decision"], "REVIEW")

    def test_non_datetime_evaluation_time_requires_review(self):
        self.assertEqual(self.evaluate(now="2027-03-01T00:00:00Z")["decision"], "REVIEW")

    def test_conflicting_approval_evidence_requires_review(self):
        request = valid_request()
        request["approvals"].append(
            {"type": "data_steward", "status": "rejected", "reference": "fake-c"}
        )
        self.assertEqual(self.evaluate(request=request)["decision"], "REVIEW")


if __name__ == "__main__":
    unittest.main()
