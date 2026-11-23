"""Adversarial tests for the isolated DRF signed-evidence adapter."""
import base64
import json
import os
import tempfile
from datetime import datetime, timezone
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from django.conf import settings

if not settings.configured:
    settings.configure(
        SECRET_KEY="synthetic-test-only",
        USE_TZ=True,
        INSTALLED_APPS=["django.contrib.auth", "django.contrib.contenttypes"],
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
from approval_evidence import sign_approval_evidence


FIXED_SERVER_TIME = datetime(2027, 6, 1, 12, 0, tzinfo=timezone.utc)
SECRET = base64.b64encode(b"test-only-secret-material-32-bytes!!").decode("ascii")
KEYRING = {
    "test-key-2027": {
        "issuer_id": "synthetic-governance-issuer",
        "secret": SECRET,
    },
    "retired-test-key": {
        "issuer_id": "synthetic-governance-issuer",
        "secret": base64.b64encode(b"retired-test-secret-material-32!!").decode("ascii"),
    },
}


class PolicyEvaluationApiTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.database_path = os.path.join(self.temp_dir.name, "approvals.sqlite3")
        self.factory = APIRequestFactory()
        self.view = PolicyEvaluationView.as_view()
        self.user = SimpleNamespace(is_authenticated=True, pk="synthetic-test-user")
        self.env = patch.dict(os.environ, {
            "AIDORA_APPROVAL_STORE_DB": self.database_path,
            "AIDORA_APPROVAL_HMAC_KEYS": json.dumps(KEYRING),
            "AIDORA_APPROVAL_ACTIVE_KEY_ID": "test-key-2027",
        })
        self.env.start()
        self.addCleanup(self.env.stop)

    def claims(self, **overrides):
        claims = {
            "approval_id": "approval-001",
            "issuer_id": "synthetic-governance-issuer",
            "subject_id": "synthetic-test-user",
            "policy_id": "synthetic-api-policy",
            "policy_version": "1",
            "purpose": "synthetic_method_validation",
            "action": "run_aggregate_test",
            "context": {"environment": "approved_sandbox"},
            "status": "approved",
            "issued_at": "2027-06-01T11:00:00Z",
            "expires_at": "2027-06-02T11:00:00Z",
        }
        claims.update(overrides)
        return claims

    def token(self, claims=None, key_id="test-key-2027"):
        return sign_approval_evidence(
            claims or self.claims(), key_id=key_id, keyring=KEYRING
        )

    def payload(self, **overrides):
        body = {
            "purpose": "synthetic_method_validation",
            "action": "run_aggregate_test",
            "approval_references": [self.token()],
            "context": {"environment": "approved_sandbox"},
        }
        body.update(overrides)
        return body

    def post(self, payload, *, server_time=FIXED_SERVER_TIME, authenticated=True, user=None):
        request = self.factory.post("/synthetic-policy/evaluate/", payload, format="json")
        if authenticated:
            force_authenticate(request, user=user or self.user)
        with patch.object(api.timezone, "now", return_value=server_time):
            return self.view(request)

    def test_valid_signed_scoped_evidence_allows_once(self):
        response = self.post(self.payload())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["decision"], "ALLOW")

    def test_replay_is_rejected_after_store_reopens(self):
        self.assertEqual(self.post(self.payload()).data["decision"], "ALLOW")
        response = self.post(self.payload())
        self.assertEqual(response.data["decision"], "REVIEW")
        self.assertEqual(response.data["reason_codes"], ["approval_reference_revoked_or_already_used"])

    def test_evidence_for_another_subject_requires_review(self):
        token = self.token(self.claims(subject_id="different-user"))
        response = self.post(self.payload(approval_references=[token]))
        self.assertEqual(response.data["decision"], "REVIEW")

    def test_wrong_policy_version_requires_review(self):
        token = self.token(self.claims(policy_version="99"))
        response = self.post(self.payload(approval_references=[token]))
        self.assertEqual(response.data["decision"], "REVIEW")

    def test_tampered_signature_requires_review(self):
        token = self.token()
        parts = token.split(".")
        parts[2] = ("A" if parts[2][0] != "A" else "B") + parts[2][1:]
        response = self.post(self.payload(approval_references=[".".join(parts)]))
        self.assertEqual(response.data["decision"], "REVIEW")

    def test_unknown_key_requires_review(self):
        token = self.token(key_id="retired-test-key")
        # Remove the old key from the trusted keyring: rotation retires trust.
        reduced = {"test-key-2027": KEYRING["test-key-2027"]}
        with patch.dict(os.environ, {"AIDORA_APPROVAL_HMAC_KEYS": json.dumps(reduced)}):
            response = self.post(self.payload(approval_references=[token]))
        self.assertEqual(response.data["decision"], "REVIEW")

    def test_previous_key_remains_verifiable_during_rotation_window(self):
        token = self.token(key_id="retired-test-key")
        response = self.post(self.payload(approval_references=[token]))
        self.assertEqual(response.data["decision"], "ALLOW")

    def test_expired_evidence_requires_review(self):
        token = self.token(self.claims(expires_at="2027-06-01T12:00:00Z"))
        response = self.post(self.payload(approval_references=[token]))
        self.assertEqual(response.data["decision"], "REVIEW")

    def test_revoked_evidence_requires_review(self):
        from approval_store import SQLiteApprovalStore
        SQLiteApprovalStore().revoke(
            "approval-001",
            revoked_at=FIXED_SERVER_TIME.isoformat(),
            revoked_by="synthetic-revocation-authority",
            reason="test revocation",
        )
        response = self.post(self.payload())
        self.assertEqual(response.data["decision"], "REVIEW")
        self.assertEqual(response.data["reason_codes"], ["approval_revoked"])

    def test_missing_key_configuration_fails_closed(self):
        with patch.dict(os.environ, {}, clear=True):
            response = self.post(self.payload())
        self.assertEqual(response.data["decision"], "REVIEW")
        self.assertEqual(
            response.data["reason_codes"],
            ["approval_trust_configuration_unavailable"],
        )

    def test_missing_durable_store_fails_closed(self):
        with patch.dict(os.environ, {"AIDORA_APPROVAL_STORE_DB": ""}):
            response = self.post(self.payload())
        self.assertEqual(response.data["decision"], "REVIEW")
        self.assertEqual(
            response.data["reason_codes"],
            ["durable_approval_store_not_configured"],
        )

    def test_anonymous_request_is_rejected(self):
        response = self.post(self.payload(), authenticated=False)
        self.assertEqual(response.status_code, 401)

    def test_denied_purpose_cannot_be_overridden_by_valid_evidence(self):
        response = self.post(self.payload(purpose="commercial_model_training"))
        self.assertEqual(response.data["decision"], "DENY")

    def test_unknown_request_field_is_rejected(self):
        response = self.post(self.payload(now="2027-01-01T00:00:00Z"))
        self.assertEqual(response.status_code, 400)

    def test_duplicate_token_is_rejected(self):
        token = self.token()
        response = self.post(self.payload(approval_references=[token, token]))
        self.assertEqual(response.data["decision"], "REVIEW")


if __name__ == "__main__":
    unittest.main()
