"""DRF adapter for a signed-evidence synthetic policy demonstration.

Never deploy or use this module to authorize real or sensitive data access.
"""
from pathlib import Path
import sys

from django.utils import timezone
from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

_CORE_DIR = Path(__file__).resolve().parents[1] / "community-policy-check"
if str(_CORE_DIR) not in sys.path:
    sys.path.insert(0, str(_CORE_DIR))

from policy_check import evaluate_policy
from approval_store import ApprovalStoreNotConfigured, SQLiteApprovalStore
from approval_evidence import (
    ApprovalEvidenceError,
    load_keyring_from_environment,
    verify_approval_evidence,
)


# Deliberately fixed synthetic policy. This is not a persistent or trusted
# policy registry and must never be treated as one.
TRUSTED_SYNTHETIC_POLICY = {
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


class PolicyEvaluationInputSerializer(serializers.Serializer):
    purpose = serializers.CharField()
    action = serializers.CharField()
    approval_references = serializers.ListField(
        child=serializers.CharField(), allow_empty=False
    )
    context = serializers.DictField()


def _review(reason_code):
    return Response({
        "decision": "REVIEW",
        "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
        "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
        "reason_codes": [reason_code],
    })


class PolicyEvaluationView(APIView):
    """Resolve policy server-side and verify issuer-authenticated evidence."""

    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        allowed_fields = set(PolicyEvaluationInputSerializer().fields)
        supplied_fields = set(request.data.keys())
        unexpected_fields = supplied_fields - allowed_fields
        if unexpected_fields:
            return Response({
                "detail": "Unexpected request fields are not accepted.",
                "unexpected_fields": sorted(unexpected_fields),
            }, status=400)

        serializer = PolicyEvaluationInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        values = serializer.validated_data
        now = timezone.now()

        # Policy denials are evaluated first and cannot be overridden by
        # otherwise valid approval evidence.
        preliminary = evaluate_policy(
            TRUSTED_SYNTHETIC_POLICY,
            {
                "purpose": values["purpose"],
                "action": values["action"],
                "approvals": [],
                "context": values["context"],
            },
            now=now,
        )
        if preliminary["decision"] == "DENY":
            return Response(preliminary)

        references = values["approval_references"]
        if len(references) != len(set(references)):
            return _review("duplicate_approval_reference")

        try:
            keyring, _active_key_id = load_keyring_from_environment()
            store = SQLiteApprovalStore()
        except ApprovalEvidenceError:
            return _review("approval_trust_configuration_unavailable")
        except ApprovalStoreNotConfigured:
            return _review("durable_approval_store_not_configured")

        approvals = []
        approval_ids = []
        for token in references:
            try:
                claims = verify_approval_evidence(
                    token,
                    keyring=keyring,
                    expected_subject_id=str(getattr(request.user, "pk", "")),
                    expected_policy_id=TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    expected_policy_version=TRUSTED_SYNTHETIC_POLICY["version"],
                    expected_purpose=values["purpose"],
                    expected_action=values["action"],
                    expected_context=values["context"],
                    now=now,
                )
            except ApprovalEvidenceError:
                return _review("approval_evidence_not_verified")

            approval_id = claims["approval_id"]
            try:
                if store.is_revoked(approval_id):
                    return _review("approval_revoked")
            except Exception:
                return _review("approval_revocation_check_failed")

            approval_ids.append(approval_id)
            approvals.append({
                "type": "community_governance",
                "status": "approved",
                "reference": approval_id,
            })

        result = evaluate_policy(
            TRUSTED_SYNTHETIC_POLICY,
            {
                "purpose": values["purpose"],
                "action": values["action"],
                "approvals": approvals,
                "context": values["context"],
            },
            now=now,
        )

        if result["decision"] == "ALLOW":
            try:
                consumed = store.consume_many(
                    approval_ids,
                    consumed_at=now.isoformat(),
                    subject_id=str(getattr(request.user, "pk", "")),
                    policy_id=TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    policy_version=TRUSTED_SYNTHETIC_POLICY["version"],
                )
            except Exception:
                return _review("durable_approval_store_unavailable")
            if not consumed:
                # The transaction also checks revocation, closing the race
                # between the earlier explanatory check and consumption.
                return _review("approval_reference_revoked_or_already_used")
        return Response(result)
