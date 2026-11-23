"""Adversarial tests for the isolated DRF synthetic adapter."""
from datetime import datetime, timezone
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from django.conf import settings

if not settings.configured:
    settings.configure(
        SECRET_KEY="synthetic-test-only",
        USE_TZ=True,
        REST_FRAMEWORK={
            "DEFAULT_AUTHENTICATION_CLASSES": [
                "rest_framework.authentication.BasicAuthentication",
            ],
            "DEFAULT_PERMISSION_CLASSES": [],
        },
    )

import django
django.setup()

from rest_framework.test import APIRequestFactory, force_authenticate

import api
from api import PolicyEvaluationView


FIXED_SERVER_TIME = datetime(2027, 6, 1, 12, 0, tzinfo=timezone.utc)


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
        }
        body.update(overrides)
        return body

    def post(self, payload, *, server_time=FIXED_SERVER_TIME, authenticated=True):
        request = self.factory.post("/synthetic-policy/evaluate/", payload, format="json")
        if authenticated:
            force_authenticate(request, user=self.user)
        with patch.object(api.timezone, "now", return_value=server_time):
            return self.view(request)

    def test_server_resolved_synthetic_evidence_allows(self):
        response = self.post(self.payload())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["decision"], "ALLOW")
        self.assertEqual(response.data["policy_id"], "synthetic-api-policy")

    def test_anonymous_request_is_rejected(self):
        response = self.post(self.payload(), authenticated=False)
        self.assertEqual(response.status_code, 401)

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

    def test_caller_supplied_evaluation_time_is_rejected(self):
        payload = self.payload(now="2027-01-01T00:00:00Z")
        response = self.post(payload)
        self.assertEqual(response.status_code, 400)
        self.assertIn("now", response.data["unexpected_fields"])

    def test_server_time_after_policy_expiry_denies(self):
        after_expiry = datetime(2028, 1, 1, tzinfo=timezone.utc)
        response = self.post(self.payload(), server_time=after_expiry)
        self.assertEqual(response.data["decision"], "DENY")
        self.assertEqual(response.data["reason_codes"], ["policy_expired"])

    def test_non_object_context_is_rejected(self):
        response = self.post(self.payload(context=["not", "an", "object"]))
        self.assertEqual(response.status_code, 400)

    def test_empty_approval_reference_list_is_rejected(self):
        response = self.post(self.payload(approval_references=[]))
        self.assertEqual(response.status_code, 400)


if __name__ == "__main__":
    unittest.main()
