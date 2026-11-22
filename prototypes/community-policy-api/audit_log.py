"""Synthetic hash-chained audit log for policy-evaluation demonstrations.

This is an in-memory integrity illustration, NOT durable or tamper-proof storage.
A real system needs independently protected storage and externally anchored
checkpoints to detect truncation of the final event.
"""
from __future__ import annotations

from datetime import datetime
import hashlib
import json
from typing import Any


GENESIS_HASH = "0" * 64
ALLOWED_DECISIONS = {"ALLOW", "DENY", "REVIEW"}
EVENT_FIELDS = {
    "sequence", "evaluated_at", "decision", "policy_id",
    "policy_version", "reason_codes", "previous_hash",
}


def _canonical_json(value: dict[str, Any]) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def _event_hash(event_without_hash: dict[str, Any]) -> str:
    return hashlib.sha256(_canonical_json(event_without_hash)).hexdigest()


def append_event(log: list[dict[str, Any]], evaluation: dict[str, Any], *, evaluated_at: str) -> dict[str, Any]:
    """Append a minimal synthetic decision event to the supplied list."""
    if not isinstance(log, list) or not isinstance(evaluation, dict):
        raise TypeError("log and evaluation must be list/object")
    decision = evaluation.get("decision")
    policy_id = evaluation.get("policy_id")
    policy_version = evaluation.get("policy_version")
    reason_codes = evaluation.get("reason_codes")
    if decision not in ALLOWED_DECISIONS:
        raise ValueError("evaluation decision is invalid")
    if not isinstance(policy_id, str) or not policy_id:
        raise ValueError("policy_id is required")
    if not isinstance(policy_version, str) or not policy_version:
        raise ValueError("policy_version is required")
    if not isinstance(reason_codes, list) or not reason_codes or any(not isinstance(x, str) or not x for x in reason_codes):
        raise ValueError("reason_codes must be a non-empty list of strings")
    if not isinstance(evaluated_at, str):
        raise ValueError("evaluated_at must be a timezone-aware ISO-8601 string")
    try:
        parsed = datetime.fromisoformat(evaluated_at.replace("Z", "+00:00"))
    except ValueError as exc:
        raise ValueError("evaluated_at must be a timezone-aware ISO-8601 string") from exc
    if parsed.tzinfo is None or parsed.utcoffset() is None:
        raise ValueError("evaluated_at must include a timezone")

    previous_hash = log[-1].get("event_hash") if log else GENESIS_HASH
    if not isinstance(previous_hash, str) or len(previous_hash) != 64:
        raise ValueError("previous event hash is malformed")
    event = {
        "sequence": len(log) + 1,
        "evaluated_at": evaluated_at,
        "decision": decision,
        "policy_id": policy_id,
        "policy_version": policy_version,
        "reason_codes": list(reason_codes),
        "previous_hash": previous_hash,
    }
    event["event_hash"] = _event_hash(event)
    log.append(event)
    return event


def verify_log(log: Any) -> dict[str, Any]:
    """Verify event structure, sequence, hash links, and event hashes."""
    if not isinstance(log, list):
        return {"valid": False, "checked_events": 0, "reason": "log_not_a_list"}
    expected_previous = GENESIS_HASH
    for index, event in enumerate(log, start=1):
        checked = index - 1
        if not isinstance(event, dict):
            return {"valid": False, "checked_events": checked, "reason": "event_not_an_object"}
        if set(event) != EVENT_FIELDS | {"event_hash"}:
            return {"valid": False, "checked_events": checked, "reason": "event_fields_invalid"}
        if event.get("sequence") != index:
            return {"valid": False, "checked_events": checked, "reason": "sequence_mismatch"}
        if event.get("previous_hash") != expected_previous:
            return {"valid": False, "checked_events": checked, "reason": "previous_hash_mismatch"}
        if event.get("decision") not in ALLOWED_DECISIONS:
            return {"valid": False, "checked_events": checked, "reason": "decision_invalid"}
        if not isinstance(event.get("reason_codes"), list) or any(not isinstance(x, str) or not x for x in event["reason_codes"]):
            return {"valid": False, "checked_events": checked, "reason": "reason_codes_invalid"}
        try:
            timestamp = datetime.fromisoformat(event["evaluated_at"].replace("Z", "+00:00"))
            if timestamp.tzinfo is None or timestamp.utcoffset() is None:
                raise ValueError
        except (TypeError, ValueError, AttributeError):
            return {"valid": False, "checked_events": checked, "reason": "timestamp_invalid"}
        unsigned = {key: value for key, value in event.items() if key != "event_hash"}
        calculated = _event_hash(unsigned)
        if event.get("event_hash") != calculated:
            return {"valid": False, "checked_events": checked, "reason": "event_hash_mismatch"}
        expected_previous = calculated
    return {"valid": True, "checked_events": len(log), "reason": "chain_valid"}
