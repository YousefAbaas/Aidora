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

The test suite uses DRF's request factory and an authenticated synthetic test principal. It covers a permitted request, a denied purpose, and malformed inputs.

## API contract

`POST /synthetic-policy/evaluate/` (the path is illustrative; this prototype does not register a URL route).

Request JSON:

- `policy`: synthetic policy object accepted by `community-policy-check/policy_check.py`
- `request`: synthetic request object
- `now`: timezone-aware ISO-8601 timestamp used for deterministic evaluation

A successful evaluation returns HTTP 200 with `decision` (`ALLOW`, `DENY`, or `REVIEW`), policy identifiers, and reason codes. Invalid request structure returns HTTP 400. The view requires authentication through DRF's `IsAuthenticated` permission; a real deployment would also need an explicitly designed identity, authorization, audit, and operational security model.

## Scope and safety limits

- This is not connected to Aidora's production backend, SRHIN, or any external service.
- It uses synthetic examples only. Never submit real health, participant, refugee, or other sensitive data.
- The endpoint is not mounted or deployable as-is; no URL configuration or production settings are supplied.
- The adapter does not verify the authenticity or authority of approval references.
- An `ALLOW` result is not legal, ethical, contractual, or community approval and does not itself enforce access restrictions.
- Do not use it to protect real data. Any host-specific implementation must first be co-designed and validated with the host and affected communities, and must reuse existing governance tools where appropriate.

The core evaluator and its limitations are documented in `../community-policy-check/README.md`.
