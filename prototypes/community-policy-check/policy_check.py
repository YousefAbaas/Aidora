"""Synthetic, fail-closed policy check reference prototype.

This module is intentionally small and dependency-free. It is not a production
authorization system or a standards-conformant GA4GH/ODRL implementation.
"""
from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List


def _parse_aware_datetime(value: Any) -> datetime:
    if not isinstance(value, str):
        raise ValueError("timestamp must be a string")
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None or parsed.utcoffset() is None:
        raise ValueError("timestamp must include a timezone")
    return parsed


def _result(
    decision: str,
    policy: Dict[str, Any],
    reason_codes: List[str],
) -> Dict[str, Any]:
    return {
        "decision": decision,
        "policy_id": policy.get("policy_id") if isinstance(policy, dict) else None,
        "policy_version": policy.get("version") if isinstance(policy, dict) else None,
        "reason_codes": reason_codes,
    }


def evaluate_policy(
    policy: Dict[str, Any],
    request: Dict[str, Any],
    *,
    now: datetime,
) -> Dict[str, Any]:
    """Evaluate a synthetic request and return ALLOW, DENY, or REVIEW.

    ALLOW is possible only when every required condition is explicit and met.
    Missing or malformed information returns REVIEW, never ALLOW.
    """
    if not isinstance(policy, dict) or not isinstance(request, dict):
        return _result("REVIEW", {}, ["invalid_policy_or_request"])

    if not isinstance(now, datetime):
        return _result("REVIEW", policy, ["evaluation_time_invalid"])
    if now.tzinfo is None or now.utcoffset() is None:
        return _result("REVIEW", policy, ["evaluation_time_missing_timezone"])

    required_policy_fields = (
        "policy_id",
        "version",
        "status",
        "effective_from",
        "allowed_purposes",
        "denied_purposes",
        "allowed_actions",
        "denied_actions",
        "required_approvals",
        "required_context",
    )
    if any(field not in policy for field in required_policy_fields):
        return _result("REVIEW", policy, ["policy_fields_incomplete"])
    if any(not isinstance(policy[field], str) or not policy[field] for field in ("policy_id", "version", "status")):
        return _result("REVIEW", policy, ["policy_identity_invalid"])
    if "review_required" in policy and not isinstance(policy["review_required"], bool):
        return _result("REVIEW", policy, ["review_flag_invalid"])

    try:
        effective_from = _parse_aware_datetime(policy["effective_from"])
        expires_at = (
            _parse_aware_datetime(policy["expires_at"])
            if policy.get("expires_at") is not None
            else None
        )
    except (TypeError, ValueError):
        return _result("REVIEW", policy, ["policy_timestamp_invalid"])

    if policy["status"] == "revoked":
        return _result("DENY", policy, ["policy_revoked"])
    if policy["status"] != "active":
        return _result("REVIEW", policy, ["policy_not_active"])
    if now < effective_from:
        return _result("REVIEW", policy, ["policy_not_yet_effective"])
    if expires_at is not None and now >= expires_at:
        return _result("DENY", policy, ["policy_expired"])

    list_fields = (
        "allowed_purposes",
        "denied_purposes",
        "allowed_actions",
        "denied_actions",
        "required_approvals",
    )
    if any(
        not isinstance(policy[field], list)
        or any(not isinstance(item, str) or not item for item in policy[field])
        for field in list_fields
    ):
        return _result("REVIEW", policy, ["policy_list_invalid"])

    if not isinstance(policy["required_context"], dict):
        return _result("REVIEW", policy, ["policy_context_invalid"])

    purpose = request.get("purpose")
    action = request.get("action")
    if not isinstance(purpose, str) or not purpose:
        return _result("REVIEW", policy, ["request_purpose_missing"])
    if not isinstance(action, str) or not action:
        return _result("REVIEW", policy, ["request_action_missing"])

    if purpose in policy["denied_purposes"]:
        return _result("DENY", policy, ["purpose_explicitly_denied"])
    if action in policy["denied_actions"]:
        return _result("DENY", policy, ["action_explicitly_denied"])
    if purpose not in policy["allowed_purposes"]:
        return _result("DENY", policy, ["purpose_not_explicitly_allowed"])
    if action not in policy["allowed_actions"]:
        return _result("DENY", policy, ["action_not_explicitly_allowed"])

    approvals = request.get("approvals")
    if not isinstance(approvals, list):
        return _result("REVIEW", policy, ["approval_evidence_missing"])

    approval_status: Dict[str, str] = {}
    for approval in approvals:
        if not isinstance(approval, dict):
            return _result("REVIEW", policy, ["approval_evidence_malformed"])
        approval_type = approval.get("type")
        status = approval.get("status")
        reference = approval.get("reference")
        if not all(isinstance(value, str) and value for value in (approval_type, status, reference)):
            return _result("REVIEW", policy, ["approval_evidence_incomplete"])
        if status not in {"approved", "rejected", "pending"}:
            return _result("REVIEW", policy, ["approval_status_unrecognised"])
        # A second record for the same approval type is ambiguous even when
        # the status matches: the evaluator cannot establish which record is
        # authoritative or whether one was substituted.
        if approval_type in approval_status:
            return _result("REVIEW", policy, ["duplicate_or_conflicting_approval_evidence"])
        approval_status[approval_type] = status

    for required_type in policy["required_approvals"]:
        status = approval_status.get(required_type)
        if status == "rejected":
            return _result("DENY", policy, ["required_approval_rejected"])
        if status != "approved":
            return _result("REVIEW", policy, ["required_approval_not_verified"])

    context = request.get("context")
    if not isinstance(context, dict):
        return _result("REVIEW", policy, ["request_context_missing"])

    for key, expected in policy["required_context"].items():
        if key not in context:
            return _result("REVIEW", policy, ["required_context_missing"])
        if context[key] != expected:
            return _result("DENY", policy, ["required_context_condition_failed"])

    if policy.get("review_required") is True:
        return _result("REVIEW", policy, ["policy_requires_human_review"])

    return _result("ALLOW", policy, ["all_explicit_conditions_satisfied"])
