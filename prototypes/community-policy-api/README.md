# Synthetic community-policy API adapter

**Status:** experimental reference adapter for discussion and local testing only.

This directory wraps the dependency-free policy evaluator in a small Django REST Framework view. It is deliberately separate from Aidora's application and does not add routes, models, migrations, or settings to the Aidora backend.

## Run locally

Use Python 3.12+ in a disposable virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m unittest -v
```

The test suite uses DRF's request factory and an authenticated synthetic test principal. It covers server-side policy resolution, known/unknown/duplicate approval references, attempts to submit a caller-controlled policy, denied purposes, expiry, and malformed inputs.

## API contract

`POST /synthetic-policy/evaluate/` (the path is illustrative; this prototype does not register a URL route).

Request JSON:

- `purpose`, `action`, `context`: synthetic request attributes
- `approval_references`: references resolved against a fixed, fake in-memory evidence map
- `now`: timezone-aware ISO-8601 timestamp used for deterministic evaluation

The adapter does **not** accept a caller-supplied policy. It resolves a fixed synthetic policy inside the server-side module and maps approval references to synthetic evidence. This is a demonstration of the trust-boundary shape only; the in-memory fixtures are public source code, mutable at runtime, non-persistent, and not cryptographically authenticated.

A successful evaluation returns HTTP 200 with `decision` (`ALLOW`, `DENY`, or `REVIEW`), policy identifiers, and reason codes. Invalid request structure returns HTTP 400. The view requires authentication through DRF's `IsAuthenticated` permission; a real deployment would also need an explicitly designed identity, authorization, audit, and operational security model.

## Scope and safety limits

- This is not connected to Aidora's production backend, SRHIN, or any external service.
- It uses synthetic examples only. Never submit real health, participant, refugee, or other sensitive data.
- The endpoint is not mounted or deployable as-is; no URL configuration or production settings are supplied.
- The adapter only recognizes hard-coded synthetic approval references. This is not real authentication, authority verification, a signed evidence registry, or protection against source/runtime compromise.
- The underlying core evaluator remains a pure function that trusts its policy and normalized approval inputs; direct callers must not treat it as a security boundary.
- An `ALLOW` result is not legal, ethical, contractual, or community approval and does not itself enforce access restrictions.
- Do not use it to protect real data. Any host-specific implementation must first be co-designed and validated with the host and affected communities, and must reuse existing governance tools where appropriate.

The core evaluator and its limitations are documented in `../community-policy-check/README.md`.

## Synthetic audit-log experiment

`audit_log.py` provides a small in-memory hash-chained event log for demonstrations. It records only the decision, policy identifier/version, reason codes, timestamp, sequence, previous hash, and event hash. It deliberately does not record request context, approval references, participant information, or raw data.

Run its tests with:

```bash
python -m unittest -v test_audit_log.py
```

The adversarial tests cover event modification, middle-event deletion, reordering, previous-hash changes, event-hash changes, and malformed input. They also demonstrate an important limitation: deleting the final event leaves a valid shorter prefix. Detecting tail truncation requires an independently protected checkpoint or external anchoring of the latest chain hash.

This implementation is an integrity demonstration only. The list is mutable in memory, hashes are not signatures, and there is no durable or independently protected storage. It is not an immutable audit system and must not be used for real or sensitive data.
