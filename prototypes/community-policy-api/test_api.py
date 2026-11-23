"""Adversarial tests for the isolated DRF signed-evidence adapter."""
import base64
import json
import os
import tempfile
from datetime import datetime, timezone
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from django.conf import settings

if not settings.configured:
    settings.configure(
        SECRET_KEY="synthetic-test-only",
        USE_TZ=True,
        INSTALLED_APPS=["django.contrib.auth", "django.contrib.contenttypes"],
        REST_FRAMEWORK={
            "DEFAULT_AUTHENTICATION_CLASSES": [
                "rest_framework.authentication.BasicAuthentication",
            ],
            "DEFAULT_PERMISSION_CLASSES": [],
        },
    )

import django
django.setup()

from rest_framework.test import APIRequestFactory, force_authenticate

import api
from api import PolicyEvaluationView
from approval_evidence import sign_approval_evidence


FIXED_SERVER_TIME = datetime(2027, 6, 1, 12, 0, tzinfo=timezone.utc)
PRIVATE_KEYS = {
    "test-key-2027": Ed25519PrivateKey.from_private_bytes(bytes(range(32))),
    "retired-test-key": Ed25519PrivateKey.from_private_bytes(bytes(range(1, 33))),
}
KEYRING = {
    key_id: {
        "issuer_id": "synthetic-governance-issuer",
        "public_key": base64.b64encode(
            private_key.public_key().public_bytes(
                encoding=serialization.Encoding.Raw,
                format=serialization.PublicFormat.Raw,
            )
        ).decode("ascii"),
    }
    for key_id, private_key in PRIVATE_KEYS.items()
}
