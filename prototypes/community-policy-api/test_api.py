"""Adversarial tests for the isolated DRF synthetic adapter."""
from types import SimpleNamespace
import unittest

from django.conf import settings

if not settings.configured:
    settings.configure(
        SECRET_KEY="synthetic-test-only",
        USE_TZ=True,
        REST_FRAMEWORK={
            "DEFAULT_AUTHENTICATION_CLASSES": [],
            "DEFAULT_PERMISSION_CLASSES": [],
        },
    )

import django
django.setup()

from rest_framework.test import APIRequestFactory, force_authenticate

from api import PolicyEvaluationView


class PolicyEvaluationApiTests(unittest.TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = PolicyEvaluationView.as_view()
        self.user = SimpleNamespace(is_authenticated=True)

    def payload(self, **overrides):
        body = {
            "purpose": "synthetic_method_validation",
            "action": "run_aggregate_test",
            "approval_references": ["synthetic-approval-001"],
            "context": {"environment": "approved_sandbox"},
            "now": "2027-06-01T12:00:00Z",
        }
        body.update(overrides)
        return body

    def post(self, payload):
        request = self.factory.post("/synthetic-policy/evaluate/", payload, format="json")
        force_authenticate(request, user=self.user)
        return self.view(request)

    def test_server_resolved_synthetic_evidence_allows(self):
        response = self.post(self.payload())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["decision"], "ALLOW")
        self.assertEqual(response.data["policy_id"], "synthetic-api-policy")

    def test_denied_purpose_cannot_be_overridden_by_valid_approval(self):
        response = self.post(self.payload(purpose="commercial_model_training"))
        self.assertEqual(response.data["decision"], "DENY")

    def test_unknown_approval_reference_requires_review(self):
        response = self.post(self.payload(approval_references=["attacker-fabricated"]))
        self.assertEqual(response.data["decision"], "REVIEW")
        self.assertEqual(response.data["reason_codes"], ["approval_reference_not_verified"])

    def test_duplicate_approval_reference_requires_review(self):
        response = self.post(self.payload(
            approval_references=["synthetic-approval-001", "synthetic-approval-001"]
        ))
        self.assertEqual(response.data["decision"], "REVIEW")

    def test_caller_supplied_policy_is_rejected(self):
        payload = self.payload()
        payload["policy"] = {
            "allowed_purposes": ["commercial_model_training"],
            "denied_purposes": [],
        }
        response = self.post(payload)
        self.assertEqual(response.status_code, 400)

    def test_missing_timestamp_is_rejected(self):
        payload = self.payload()
        del payload["now"]
        self.assertEqual(self.post(payload).status_code, 400)

    def test_non_object_context_is_rejected(self):
        self.assertEqual(self.post(self.payload(context=["not", "an", "object"])).status_code, 400)

    def test_expired_policy_denies(self):
        response = self.post(self.payload(now="2028-01-01T00:00:00Z"))
        self.assertEqual(response.data["decision"], "DENY")


if __name__ == "__main__":
    unittest.main()
