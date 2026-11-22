"""Unit tests for the synthetic policy-checking prototype."""
import unittest
from datetime import datetime, timezone

from policy_engine import evaluate_request

NOW = datetime(2026, 11, 23, 12, 0, tzinfo=timezone.utc)


def sample_policy():
    return {
        "policy_id": "synthetic-policy-001",
        "policy_version": "1.0",
        "dataset_ref": "synthetic-dataset-alpha",
        "status": "active",
        "allowed_purposes": ["approved_research"],
        "allowed_roles": ["approved_researcher"],
        "authority_decision_ref": "synthetic-decision-001",
        "expires_at": "2027-01-01T00:00:00Z",
    }


def sample_request():
    return {
        "dataset_ref": "synthetic-dataset-alpha",
        "policy_version": "1.0",
        "purpose": "approved_research",
        "actor_role": "approved_researcher",
    }


class PolicyEngineTests(unittest.TestCase):
    def test_all_declared_checks_pass(self):
        result = evaluate_request(sample_policy(), sample_request(), now=NOW)
        self.assertEqual(result["decision"], "ALLOW")

    def test_missing_request_field_requires_review(self):
        data = sample_request()
        del data["purpose"]
        self.assertEqual(evaluate_request(sample_policy(), data, now=NOW)["decision"], "REVIEW")

    def test_missing_authority_reference_requires_review(self):
        data = sample_policy()
        data["authority_decision_ref"] = ""
        self.assertEqual(evaluate_request(data, sample_request(), now=NOW)["decision"], "REVIEW")

    def test_revoked_policy_is_denied(self):
        data = sample_policy()
        data["status"] = "revoked"
        self.assertEqual(evaluate_request(data, sample_request(), now=NOW)["reason_code"], "POLICY_REVOKED")

    def test_expired_policy_is_denied(self):
        data = sample_policy()
        data["expires_at"] = "2026-11-01T00:00:00Z"
        self.assertEqual(evaluate_request(data, sample_request(), now=NOW)["reason_code"], "POLICY_EXPIRED")

    def test_dataset_mismatch_is_denied(self):
        data = sample_request()
        data["dataset_ref"] = "another-dataset"
        self.assertEqual(evaluate_request(sample_policy(), data, now=NOW)["reason_code"], "DATASET_NOT_COVERED")

    def test_purpose_mismatch_is_denied(self):
        data = sample_request()
        data["purpose"] = "commercial_training"
        self.assertEqual(evaluate_request(sample_policy(), data, now=NOW)["reason_code"], "PURPOSE_NOT_PERMITTED")

    def test_role_mismatch_is_denied(self):
        data = sample_request()
        data["actor_role"] = "unverified_user"
        self.assertEqual(evaluate_request(sample_policy(), data, now=NOW)["reason_code"], "ROLE_NOT_PERMITTED")

    def test_policy_version_mismatch_requires_review(self):
        data = sample_request()
        data["policy_version"] = "0.9"
        self.assertEqual(evaluate_request(sample_policy(), data, now=NOW)["reason_code"], "POLICY_VERSION_MISMATCH")

    def test_naive_expiry_timestamp_requires_review(self):
        data = sample_policy()
        data["expires_at"] = "2027-01-01T00:00:00"
        self.assertEqual(evaluate_request(data, sample_request(), now=NOW)["reason_code"], "EXPIRY_INVALID_OR_TIMEZONE_MISSING")


if __name__ == "__main__":
    unittest.main()
