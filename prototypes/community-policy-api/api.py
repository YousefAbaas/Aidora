"""DRF adapter for the synthetic policy-check reference prototype.

This endpoint is an isolated demonstration only. Do not mount it in Aidora's
production API or use it to authorize access to real or sensitive data.
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


class PolicyEvaluationInputSerializer(serializers.Serializer):
    policy = serializers.JSONField()
    request = serializers.JSONField()
    now = serializers.DateTimeField()

    def validate_policy(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("Expected a policy object.")
        return value

    def validate_request(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("Expected a request object.")
        return value


class PolicyEvaluationView(APIView):
    """Evaluate synthetic input; authentication is required by default."""

    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = PolicyEvaluationInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        values = serializer.validated_data
        result = evaluate_policy(
            values["policy"],
            values["request"],
            now=values["now"],
        )
        return Response(result)
