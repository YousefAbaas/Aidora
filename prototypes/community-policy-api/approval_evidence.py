"""Ed25519-signed synthetic approval evidence for the isolated prototype.

The verifier receives public keys only. Private signing keys belong in a
separately controlled issuer process and must never be configured in the API.
This module does not establish real community authority or production key
management.
"""
from __future__ import annotations

import base64
import json
import os
import re
from datetime import datetime
from typing import Any

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import (
    Ed25519PrivateKey,
    Ed25519PublicKey,
)

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


def _decode_key(value: Any, expected_length: int) -> bytes:
    if not isinstance(value, str):
        raise ApprovalEvidenceError("approval_trust_configuration_invalid")
    try:
        decoded = base64.b64decode(value, validate=True)
    except (ValueError, TypeError) as exc:
        raise ApprovalEvidenceError("approval_trust_configuration_invalid") from exc
    if len(decoded) != expected_length:
        raise ApprovalEvidenceError("approval_trust_configuration_invalid")
    return decoded


def load_keyring_from_environment() -> dict[str, dict[str, str]]:
    """Load issuer-bound Ed25519 public keys; no private key is accepted here."""
    raw = os.environ.get("AIDORA_APPROVAL_ED25519_PUBLIC_KEYS")
    if not raw:
        raise ApprovalEvidenceError("approval_trust_configuration_missing")
    try:
        keyring = json.loads(raw)
    except (TypeError, json.JSONDecodeError) as exc:
        raise ApprovalEvidenceError("approval_trust_configuration_invalid") from exc
    if not isinstance(keyring, dict) or not keyring:
        raise ApprovalEvidenceError("approval_trust_configuration_invalid")
    for key_id, entry in keyring.items():
        if not isinstance(key_id, str) or not key_id or not isinstance(entry, dict):
            raise ApprovalEvidenceError("approval_trust_configuration_invalid")
        issuer_id = entry.get("issuer_id")
        if not isinstance(issuer_id, str) or not issuer_id:
            raise ApprovalEvidenceError("approval_trust_configuration_invalid")
        _decode_key(entry.get("public_key"), 32)
    return keyring


def sign_approval_evidence(
    claims: dict[str, Any], *, key_id: str, private_key: Ed25519PrivateKey
) -> str:
    """Issuer-side helper. Never load or expose the private key in the API."""
    if set(claims) != REQUIRED_CLAIMS:
        raise ApprovalEvidenceError("approval_claims_invalid")
    if not isinstance(private_key, Ed25519PrivateKey):
        raise ApprovalEvidenceError("approval_signing_key_invalid")
    payload = _canonical_json(claims)
    signature = private_key.sign(key_id.encode("utf-8") + b"." + payload)
    return key_id + "." + _b64url_encode(payload) + "." + _b64url_encode(signature)


def verify_approval_evidence(
    token: str, *, keyring: dict[str, dict[str, str]],
    expected_subject_id: str, expected_policy_id: str,
    expected_policy_version: str, expected_purpose: str,
    expected_action: str, expected_context: dict[str, Any], now: datetime,
) -> dict[str, Any]:
    """Verify issuer signature using public key, then enforce scope and time."""
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
        public_bytes = _decode_key(entry.get("public_key"), 32)
        payload_bytes = _b64url_decode(encoded_payload)
        supplied_signature = _b64url_decode(encoded_signature)
        claims = json.loads(payload_bytes.decode("utf-8"))
        public_key = Ed25519PublicKey.from_public_bytes(public_bytes)
    except (ApprovalEvidenceError, ValueError, TypeError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ApprovalEvidenceError("approval_evidence_malformed") from exc
    if len(supplied_signature) != 64 or not isinstance(claims, dict) or set(claims) != REQUIRED_CLAIMS:
        raise ApprovalEvidenceError("approval_evidence_malformed")
    try:
        canonical_payload = _canonical_json(claims)
    except (TypeError, ValueError, UnicodeError) as exc:
        raise ApprovalEvidenceError("approval_evidence_noncanonical") from exc
    if canonical_payload != payload_bytes:
        raise ApprovalEvidenceError("approval_evidence_noncanonical")
    try:
        public_key.verify(supplied_signature, key_id.encode("utf-8") + b"." + payload_bytes)
    except InvalidSignature as exc:
        raise ApprovalEvidenceError("approval_signature_invalid") from exc
    if claims.get("issuer_id") != entry.get("issuer_id"):
        raise ApprovalEvidenceError("approval_issuer_untrusted")
    for field, expected in (
        ("subject_id", expected_subject_id), ("policy_id", expected_policy_id),
        ("policy_version", expected_policy_version), ("purpose", expected_purpose),
        ("action", expected_action), ("context", expected_context),
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
    )) or not isinstance(claims.get("context"), dict):
        raise ApprovalEvidenceError("approval_claims_invalid")
    return claims
