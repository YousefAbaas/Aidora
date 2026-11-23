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


def _valid_timestamp(value: Any) -> bool:
    if not isinstance(value, str):
        return False
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return False
    return parsed.tzinfo is not None and parsed.utcoffset() is not None


def append_event(log: list[dict[str, Any]], evaluation: dict[str, Any], *, evaluated_at: str) -> dict[str, Any]:
    """Append an event only when the existing chain is structurally valid."""
    if not isinstance(log, list) or not isinstance(evaluation, dict):
        raise TypeError("log and evaluation must be list/object")
    if not verify_log(log)["valid"]:
        raise ValueError("cannot append to an invalid audit log")

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
    if not _valid_timestamp(evaluated_at):
        raise ValueError("evaluated_at must be a timezone-aware ISO-8601 string")

    previous_hash = log[-1]["event_hash"] if log else GENESIS_HASH
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
    """Verify event schema, sequence, hash links, and event hashes."""
    if not isinstance(log, list):
        return {"valid": False, "checked_events": 0, "reason": "log_not_a_list"}
    expected_previous = GENESIS_HASH
    for index, event in enumerate(log, start=1):
        checked = index - 1
        if not isinstance(event, dict):
            return {"valid": False, "checked_events": checked, "reason": "event_not_an_object"}
        if set(event) != EVENT_FIELDS | {"event_hash"}:
            return {"valid": False, "checked_events": checked, "reason": "event_fields_invalid"}
        sequence = event.get("sequence")
        if isinstance(sequence, bool) or not isinstance(sequence, int) or sequence != index:
            return {"valid": False, "checked_events": checked, "reason": "sequence_mismatch"}
        if not isinstance(event.get("policy_id"), str) or not event["policy_id"]:
            return {"valid": False, "checked_events": checked, "reason": "policy_id_invalid"}
        if not isinstance(event.get("policy_version"), str) or not event["policy_version"]:
            return {"valid": False, "checked_events": checked, "reason": "policy_version_invalid"}
        if event.get("decision") not in ALLOWED_DECISIONS:
            return {"valid": False, "checked_events": checked, "reason": "decision_invalid"}
        reasons = event.get("reason_codes")
        if not isinstance(reasons, list) or not reasons or any(not isinstance(x, str) or not x for x in reasons):
            return {"valid": False, "checked_events": checked, "reason": "reason_codes_invalid"}
        if not _valid_timestamp(event.get("evaluated_at")):
            return {"valid": False, "checked_events": checked, "reason": "timestamp_invalid"}
        if event.get("previous_hash") != expected_previous:
            return {"valid": False, "checked_events": checked, "reason": "previous_hash_mismatch"}
        unsigned = {key: value for key, value in event.items() if key != "event_hash"}
        calculated = _event_hash(unsigned)
        if event.get("event_hash") != calculated:
            return {"valid": False, "checked_events": checked, "reason": "event_hash_mismatch"}
        expected_previous = calculated
    return {"valid": True, "checked_events": len(log), "reason": "chain_valid"}
