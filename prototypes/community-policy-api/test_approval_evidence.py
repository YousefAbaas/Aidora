"""Unit tests for HMAC approval evidence authentication and claim validation."""
import base64
from datetime import datetime, timezone
import unittest

from approval_evidence import (
    ApprovalEvidenceError,
    sign_approval_evidence,
    verify_approval_evidence,
)


NOW = datetime(2027, 6, 1, 12, 0, tzinfo=timezone.utc)
KEYRING = {
    "issuer-key-1": {
        "issuer_id": "issuer-example",
        "secret": base64.b64encode(b"unit-test-secret-material-at-least-32-bytes").decode("ascii"),
    }
}


def claims(**overrides):
    value = {
        "approval_id": "approval-123",
        "issuer_id": "issuer-example",
        "subject_id": "subject-1",
        "policy_id": "policy-1",
        "policy_version": "3",
        "purpose": "research-validation",
        "action": "aggregate-query",
        "context": {"environment": "sandbox"},
        "status": "approved",
        "issued_at": "2027-06-01T10:00:00Z",
        "expires_at": "2027-06-02T10:00:00Z",
    }
    value.update(overrides)
    return value


def signed(value=None):
    return sign_approval_evidence(
        value or claims(), key_id="issuer-key-1", keyring=KEYRING
    )


def verify(token, **overrides):
    expected = {
        "expected_subject_id": "subject-1",
        "expected_policy_id": "policy-1",
        "expected_policy_version": "3",
        "expected_purpose": "research-validation",
        "expected_action": "aggregate-query",
        "expected_context": {"environment": "sandbox"},
        "now": NOW,
    }
    expected.update(overrides)
    return verify_approval_evidence(token, keyring=KEYRING, **expected)


class ApprovalEvidenceTests(unittest.TestCase):
    def test_valid_signature_and_scope_verify(self):
        self.assertEqual(verify(signed())["approval_id"], "approval-123")

    def test_modified_payload_is_rejected(self):
        token = signed()
        parts = token.split(".")
        parts[2] = ("A" if parts[2][0] != "A" else "B") + parts[2][1:]
        with self.assertRaises(ApprovalEvidenceError):
            verify(".".join(parts))

    def test_unknown_key_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify("unknown-key." + signed().split(".", 1)[1])

    def test_wrong_subject_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(), expected_subject_id="other-subject")

    def test_wrong_policy_scope_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(), expected_policy_version="4")

    def test_non_approved_status_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(claims(status="pending")))

    def test_expired_evidence_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(claims(expires_at="2027-06-01T12:00:00Z")))

    def test_future_issued_evidence_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(claims(issued_at="2027-06-01T12:01:00Z")))

    def test_naive_timestamp_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(claims(issued_at="2027-06-01T10:00:00")))

    def test_excessive_lifetime_is_rejected(self):
        with self.assertRaises(ApprovalEvidenceError):
            verify(signed(claims(expires_at="2027-10-01T10:00:00Z")))

    def test_wrong_issuer_key_binding_cannot_be_signed(self):
        with self.assertRaises(ApprovalEvidenceError):
            signed(claims(issuer_id="untrusted-issuer"))

    def test_extra_claim_is_rejected(self):
        malformed = claims()
        malformed["unreviewed_claim"] = True
        with self.assertRaises(ApprovalEvidenceError):
            signed(malformed)

    def test_duplicate_json_claims_are_not_produced_by_signer(self):
        with self.assertRaises(ApprovalEvidenceError):
            signed({"approval_id": "only-one-claim"})


if __name__ == "__main__":
    unittest.main()
