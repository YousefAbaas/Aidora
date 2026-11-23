"""DRF adapter for a synthetic, server-resolved policy demonstration.

Never deploy or use this module to authorize real or sensitive data access.
"""
from datetime import datetime
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


# Deliberately fixed synthetic fixture. This is not a persistent or secure
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

# Fake, in-memory approval evidence for tests/demonstration only. The evidence
# is deliberately bound to one exact subject, policy version, purpose, action,
# context and expiry. It is not a real community approval.
SYNTHETIC_APPROVALS = {
    "synthetic-approval-001": {
        "type": "community_governance",
        "status": "approved",
        "subject_id": "synthetic-test-user",
        "policy_id": "synthetic-api-policy",
        "policy_version": "1",
        "purpose": "synthetic_method_validation",
        "action": "run_aggregate_test",
        "context": {"environment": "approved_sandbox"},
        "expires_at": "2027-12-31T23:59:59Z",
    },
}

class PolicyEvaluationInputSerializer(serializers.Serializer):
    purpose = serializers.CharField()
    action = serializers.CharField()
    approval_references = serializers.ListField(
        child=serializers.CharField(), allow_empty=False
    )
    context = serializers.DictField()


def _approval_matches_request(evidence, *, subject_id, values, policy, now):
    """Require exact scope and an unexpired, timezone-aware evidence record."""
    if not isinstance(evidence, dict):
        return False
    if evidence.get("status") != "approved":
        return False
    if evidence.get("subject_id") != subject_id:
        return False
    if evidence.get("policy_id") != policy["policy_id"]:
        return False
    if evidence.get("policy_version") != policy["version"]:
        return False
    if evidence.get("purpose") != values["purpose"]:
        return False
    if evidence.get("action") != values["action"]:
        return False
    if evidence.get("context") != values["context"]:
        return False
    try:
        expires_at = datetime.fromisoformat(
            evidence["expires_at"].replace("Z", "+00:00")
        )
    except (KeyError, TypeError, ValueError):
        return False
    if expires_at.tzinfo is None or expires_at.utcoffset() is None:
        return False
    return now < expires_at


class PolicyEvaluationView(APIView):
    """Resolve policy/evidence server-side; caller cannot submit their values."""

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

        # Evaluate policy-level denials before considering approval evidence:
        # an approval can never override an explicit policy denial.
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
            return Response({
                "decision": "REVIEW",
                "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                "reason_codes": ["duplicate_approval_reference"],
            })

        approvals = []
        approval_types = set()
        subject_id = str(getattr(request.user, "pk", ""))

        for reference in references:
            evidence = SYNTHETIC_APPROVALS.get(reference)
            if evidence is None:
                return Response({
                    "decision": "REVIEW",
                    "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                    "reason_codes": ["approval_reference_not_verified"],
                })
            if not _approval_matches_request(
                evidence,
                subject_id=subject_id,
                values=values,
                policy=TRUSTED_SYNTHETIC_POLICY,
                now=now,
            ):
                return Response({
                    "decision": "REVIEW",
                    "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                    "reason_codes": ["approval_scope_or_expiry_mismatch"],
                })
            approval_type = evidence["type"]
            if approval_type in approval_types:
                return Response({
                    "decision": "REVIEW",
                    "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                    "reason_codes": ["duplicate_or_conflicting_approval_evidence"],
                })
            approval_types.add(approval_type)
            approvals.append({
                "type": approval_type,
                "status": evidence["status"],
                "reference": reference,
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
                consumed = SQLiteApprovalStore().consume_many(
                    references,
                    consumed_at=now.isoformat(),
                    subject_id=subject_id,
                    policy_id=TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    policy_version=TRUSTED_SYNTHETIC_POLICY["version"],
                )
            except ApprovalStoreNotConfigured:
                return Response({
                    "decision": "REVIEW",
                    "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                    "reason_codes": ["durable_approval_store_not_configured"],
                })
            if not consumed:
                return Response({
                    "decision": "REVIEW",
                    "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                    "reason_codes": ["approval_reference_already_used"],
                })
        return Response(result)
