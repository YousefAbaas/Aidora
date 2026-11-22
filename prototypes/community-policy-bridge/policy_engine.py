"""Experimental, host-neutral policy-checking reference prototype.

Synthetic metadata only. Not a consent system, legal decision-maker, standards
implementation, or enforcement mechanism. Callers must independently
authenticate actors, retrieve authoritative decisions, and enforce results.
"""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

REQUIRED_POLICY_FIELDS = {
    "policy_id", "policy_version", "dataset_ref", "status",
    "allowed_purposes", "allowed_roles", "authority_decision_ref", "expires_at",
}
REQUIRED_REQUEST_FIELDS = {"dataset_ref", "policy_version", "purpose", "actor_role"}


def _parse_timestamp(value: Any) -> datetime | None:
    if not isinstance(value, str) or not value.strip():
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    if parsed.tzinfo is None or parsed.utcoffset() is None:
        return None
    return parsed.astimezone(timezone.utc)


def _result(decision: str, reason_code: str, policy: dict[str, Any]) -> dict[str, str]:
    return {
        "decision": decision,
        "reason_code": reason_code,
        "policy_ref": str(policy.get("policy_id", "UNAVAILABLE")),
        "policy_version": str(policy.get("policy_version", "UNAVAILABLE")),
    }


def evaluate_request(
    policy: dict[str, Any],
    request: dict[str, Any],
    *,
    now: datetime | None = None,
) -> dict[str, str]:
    """Return ALLOW, DENY, or REVIEW; missing/ambiguous inputs never allow."""
    if not isinstance(policy, dict) or not isinstance(request, dict):
        return _result("REVIEW", "INVALID_INPUT_SHAPE", {})
    if REQUIRED_POLICY_FIELDS - policy.keys():
        return _result("REVIEW", "POLICY_FIELDS_MISSING", policy)
    if REQUIRED_REQUEST_FIELDS - request.keys():
        return _result("REVIEW", "REQUEST_FIELDS_MISSING", policy)
    if policy["status"] == "revoked":
        return _result("DENY", "POLICY_REVOKED", policy)
    if policy["status"] != "active":
        return _result("REVIEW", "POLICY_STATUS_UNRECOGNISED", policy)
    if not isinstance(policy["allowed_purposes"], list) or not policy["allowed_purposes"]:
        return _result("REVIEW", "PURPOSE_RULES_INVALID", policy)
    if not isinstance(policy["allowed_roles"], list) or not policy["allowed_roles"]:
        return _result("REVIEW", "ROLE_RULES_INVALID", policy)
    if not isinstance(policy["authority_decision_ref"], str) or not policy["authority_decision_ref"].strip():
        return _result("REVIEW", "AUTHORITY_REFERENCE_MISSING", policy)

    expiry = _parse_timestamp(policy["expires_at"])
    if expiry is None:
        return _result("REVIEW", "EXPIRY_INVALID_OR_TIMEZONE_MISSING", policy)
    evaluation_time = now or datetime.now(timezone.utc)
    if evaluation_time.tzinfo is None or evaluation_time.utcoffset() is None:
        return _result("REVIEW", "EVALUATION_TIME_MUST_BE_TIMEZONE_AWARE", policy)
    if evaluation_time.astimezone(timezone.utc) >= expiry:
        return _result("DENY", "POLICY_EXPIRED", policy)

    if request["dataset_ref"] != policy["dataset_ref"]:
        return _result("DENY", "DATASET_NOT_COVERED", policy)
    if request["policy_version"] != policy["policy_version"]:
        return _result("REVIEW", "POLICY_VERSION_MISMATCH", policy)
    if request["purpose"] not in policy["allowed_purposes"]:
        return _result("DENY", "PURPOSE_NOT_PERMITTED", policy)
    if request["actor_role"] not in policy["allowed_roles"]:
        return _result("DENY", "ROLE_NOT_PERMITTED", policy)
    return _result("ALLOW", "ALL_DECLARED_CHECKS_PASSED", policy)
