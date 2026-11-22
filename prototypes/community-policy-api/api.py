"""DRF adapter for a synthetic, server-resolved policy demonstration.

Never deploy or use this module to authorize real or sensitive data access.
"""
from pathlib import Path
import sys

from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

_CORE_DIR = Path(__file__).resolve().parents[1] / "community-policy-check"
if str(_CORE_DIR) not in sys.path:
    sys.path.insert(0, str(_CORE_DIR))

from policy_check import evaluate_policy


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

# Fake, in-memory approval evidence for tests/demonstration only.
SYNTHETIC_APPROVALS = {
    "synthetic-approval-001": {
        "type": "community_governance",
        "status": "approved",
    },
}


class PolicyEvaluationInputSerializer(serializers.Serializer):
    purpose = serializers.CharField()
    action = serializers.CharField()
    approval_references = serializers.ListField(
        child=serializers.CharField(), allow_empty=False
    )
    context = serializers.DictField()
    now = serializers.DateTimeField()


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

        approvals = []
        for reference in values["approval_references"]:
            evidence = SYNTHETIC_APPROVALS.get(reference)
            if evidence is None:
                return Response({
                    "decision": "REVIEW",
                    "policy_id": TRUSTED_SYNTHETIC_POLICY["policy_id"],
                    "policy_version": TRUSTED_SYNTHETIC_POLICY["version"],
                    "reason_codes": ["approval_reference_not_verified"],
                })
            approvals.append({
                "type": evidence["type"],
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
            now=values["now"],
        )
        return Response(result)
