"""HMAC-authenticated synthetic approval evidence for the isolated prototype.

The configured keyring is the trust anchor. This module does not create a real
community authority, identity proofing process, or production key-management
system. Keep secrets outside source control and use a secret manager in any
real deployment.
"""
from __future__ import annotations

import base64
import hashlib
import hmac
import json
import os
import re
from datetime import datetime
from typing import Any


REQUIRED_CLAIMS = {
    "approval_id", "issuer_id", "subject_id", "policy_id", "policy_version",
    "purpose", "action", "context", "status", "issued_at", "expires_at",
}
MAX_TOKEN_LENGTH = 16_384
MAX_APPROVAL_LIFETIME_SECONDS = 90 * 24 * 60 * 60


class ApprovalEvidenceError(ValueError):
    """Evidence is malformed, untrusted, out of scope, or expired."""


def _b64url_encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _b64url_decode(value: str) -> bytes:
    if not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9_-]+", value):
        raise ApprovalEvidenceError("approval_evidence_encoding_invalid")
    try:
        return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))
    except (ValueError, base64.binascii.Error) as exc:
        raise ApprovalEvidenceError("approval_evidence_encoding_invalid") from exc


def _canonical_json(value: dict[str, Any]) -> bytes:
    return json.dumps(
        value, sort_keys=True, separators=(",", ":"), ensure_ascii=False,
        allow_nan=False,
    ).encode("utf-8")


def load_keyring_from_environment() -> tuple[dict[str, dict[str, str]], str]:
    """Load trusted issuer/key mappings; secrets are base64-encoded 32+ bytes."""
    raw = os.environ.get("AIDORA_APPROVAL_HMAC_KEYS")
    active_key_id = os.environ.get("AIDORA_APPROVAL_ACTIVE_KEY_ID")
    if not raw or not active_key_id:
        raise ApprovalEvidenceError("approval_trust_configuration_missing")
    try:
        keyring = json.loads(raw)
    except (TypeError, json.JSONDecodeError) as exc:
        raise ApprovalEvidenceError("approval_trust_configuration_invalid") from exc
    if not isinstance(keyring, dict) or active_key_id not in keyring:
        raise ApprovalEvidenceError("approval_trust_configuration_invalid")
    for key_id, entry in keyring.items():
        if not isinstance(key_id, str) or not key_id or not isinstance(entry, dict):
            raise ApprovalEvidenceError("approval_trust_configuration_invalid")
        issuer_id = entry.get("issuer_id")
        secret_text = entry.get("secret")
        if not isinstance(issuer_id, str) or not issuer_id:
            raise ApprovalEvidenceError("approval_trust_configuration_invalid")
        try:
            secret = base64.b64decode(secret_text, validate=True)
        except (TypeError, ValueError) as exc:
            raise ApprovalEvidenceError("approval_trust_configuration_invalid") from exc
        if len(secret) < 32:
            raise ApprovalEvidenceError("approval_trust_configuration_invalid")
    return keyring, active_key_id


def sign_approval_evidence(
    claims: dict[str, Any], *, key_id: str, keyring: dict[str, dict[str, str]]
) -> str:
    """Issuer-side helper. The API endpoint never exposes an issuance route."""
    if set(claims) != REQUIRED_CLAIMS:
        raise ApprovalEvidenceError("approval_claims_invalid")
    entry = keyring.get(key_id)
    if not isinstance(entry, dict):
        raise ApprovalEvidenceError("approval_signing_key_unknown")
    issuer_id = entry.get("issuer_id")
    if claims.get("issuer_id") != issuer_id:
        raise ApprovalEvidenceError("approval_issuer_key_mismatch")
    try:
        secret = base64.b64decode(entry["secret"], validate=True)
        payload = _canonical_json(claims)
    except (KeyError, TypeError, ValueError) as exc:
        raise ApprovalEvidenceError("approval_signing_key_invalid") from exc
    if len(secret) < 32:
        raise ApprovalEvidenceError("approval_signing_key_invalid")
    signature = hmac.new(secret, key_id.encode("utf-8") + b"." + payload, hashlib.sha256).digest()
    return key_id + "." + _b64url_encode(payload) + "." + _b64url_encode(signature)


def verify_approval_evidence(
    token: str,
    *,
    keyring: dict[str, dict[str, str]],
    expected_subject_id: str,
    expected_policy_id: str,
    expected_policy_version: str,
    expected_purpose: str,
    expected_action: str,
    expected_context: dict[str, Any],
    now: datetime,
) -> dict[str, Any]:
    """Authenticate signature and issuer, then enforce scope and time claims."""
    if not isinstance(token, str) or len(token) > MAX_TOKEN_LENGTH:
        raise ApprovalEvidenceError("approval_evidence_malformed")
    parts = token.split(".")
    if len(parts) != 3:
        raise ApprovalEvidenceError("approval_evidence_malformed")
    key_id, encoded_payload, encoded_signature = parts
    entry = keyring.get(key_id)
    if not isinstance(entry, dict):
        raise ApprovalEvidenceError("approval_signing_key_untrusted")
    try:
        secret = base64.b64decode(entry["secret"], validate=True)
        payload_bytes = _b64url_decode(encoded_payload)
        supplied_signature = _b64url_decode(encoded_signature)
        claims = json.loads(payload_bytes.decode("utf-8"))
    except (KeyError, TypeError, ValueError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ApprovalEvidenceError("approval_evidence_malformed") from exc
    if len(secret) < 32 or not isinstance(claims, dict) or set(claims) != REQUIRED_CLAIMS:
        raise ApprovalEvidenceError("approval_evidence_malformed")
    expected_signature = hmac.new(
        secret, key_id.encode("utf-8") + b"." + payload_bytes, hashlib.sha256
    ).digest()
    if not hmac.compare_digest(supplied_signature, expected_signature):
        raise ApprovalEvidenceError("approval_signature_invalid")
    if claims.get("issuer_id") != entry.get("issuer_id"):
        raise ApprovalEvidenceError("approval_issuer_untrusted")
    for field, expected in (
        ("subject_id", expected_subject_id),
        ("policy_id", expected_policy_id),
        ("policy_version", expected_policy_version),
        ("purpose", expected_purpose),
        ("action", expected_action),
        ("context", expected_context),
    ):
        if claims.get(field) != expected:
            raise ApprovalEvidenceError("approval_scope_mismatch")
    if claims.get("status") != "approved":
        raise ApprovalEvidenceError("approval_not_approved")
    approval_id = claims.get("approval_id")
    if not isinstance(approval_id, str) or not approval_id or len(approval_id) > 256:
        raise ApprovalEvidenceError("approval_id_invalid")
    try:
        issued_at = datetime.fromisoformat(claims["issued_at"].replace("Z", "+00:00"))
        expires_at = datetime.fromisoformat(claims["expires_at"].replace("Z", "+00:00"))
    except (AttributeError, TypeError, ValueError) as exc:
        raise ApprovalEvidenceError("approval_timestamp_invalid") from exc
    if any(value.tzinfo is None or value.utcoffset() is None for value in (issued_at, expires_at)):
        raise ApprovalEvidenceError("approval_timestamp_invalid")
    if issued_at > now or expires_at <= now or expires_at <= issued_at:
        raise ApprovalEvidenceError("approval_expired_or_not_yet_valid")
    if (expires_at - issued_at).total_seconds() > MAX_APPROVAL_LIFETIME_SECONDS:
        raise ApprovalEvidenceError("approval_lifetime_exceeds_limit")
    if not all(isinstance(claims.get(field), str) and claims[field] for field in (
        "issuer_id", "subject_id", "policy_id", "policy_version", "purpose", "action"
    )):
        raise ApprovalEvidenceError("approval_claims_invalid")
    if not isinstance(claims.get("context"), dict):
        raise ApprovalEvidenceError("approval_claims_invalid")
    return claims
