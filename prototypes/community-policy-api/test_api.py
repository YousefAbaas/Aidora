"""Integration tests for the isolated DRF policy-check adapter."""
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

    def policy(self):
        return {
            "policy_id": "synthetic-api-policy",
            "version": "1",
            "status": "active",
            "effective_from": "2027-01-01T00:00:00Z",
            "expires_at": "2027-12-31T23:59:59Z",
            "allowed_purposes": ["synthetic_method_validation"],
            "denied_purposes": ["commercial_model_training"],
            "allowed_actions": ["run_aggregate_test"],
            "denied_actions": ["export_row_level_data"],
            "required_approvals": ["community_governance"],
            "required_context": {"environment": "approved_sandbox"},
            "review_required": False,
        }

    def request_body(self, purpose="synthetic_method_validation"):
        return {
            "policy": self.policy(),
            "request": {
                "purpose": purpose,
                "action": "run_aggregate_test",
                "approvals": [{
                    "type": "community_governance",
                    "status": "approved",
                    "reference": "synthetic-approval-001",
                }],
                "context": {"environment": "approved_sandbox"},
            },
            "now": "2027-06-01T12:00:00Z",
        }

    def post(self, payload):
        request = self.factory.post("/synthetic-policy/evaluate/", payload, format="json")
        force_authenticate(request, user=self.user)
        return self.view(request)

    def test_explicitly_permitted_request_returns_allow(self):
        response = self.post(self.request_body())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["decision"], "ALLOW")
        self.assertEqual(response.data["policy_id"], "synthetic-api-policy")

    def test_explicitly_denied_purpose_returns_deny(self):
        response = self.post(self.request_body("commercial_model_training"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["decision"], "DENY")

    def test_missing_timestamp_is_rejected_as_bad_input(self):
        payload = self.request_body()
        del payload["now"]
        response = self.post(payload)
        self.assertEqual(response.status_code, 400)

    def test_non_object_policy_is_rejected(self):
        payload = self.request_body()
        payload["policy"] = ["not", "an", "object"]
        response = self.post(payload)
        self.assertEqual(response.status_code, 400)


if __name__ == "__main__":
    unittest.main()
