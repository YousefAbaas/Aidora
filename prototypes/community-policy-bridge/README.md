# Community Policy Bridge — experimental reference prototype

**Status:** isolated technical experiment; not an SRHIN integration, approved design, or validated response to an established host need.

This small Python prototype demonstrates one narrow engineering question: can a downstream workflow check a minimal, versioned policy envelope and fail closed when a declared condition is missing, expired, or contradictory?

It uses synthetic identifiers and policy metadata only. It does not process health data, personal data, consent records, or real community decisions.

## Run

From this directory:

```bash
python -m unittest -v
```

The tests use only the Python standard library.

## Illustrative input

See `examples/synthetic_policy.json`. A matching request can be passed to `evaluate_request(policy, request)` in `policy_engine.py`.

The evaluator returns one of:

- `ALLOW`: all checks represented in this demonstration passed.
- `DENY`: a declared rule explicitly excludes the request, or the policy is revoked/expired.
- `REVIEW`: required information is missing, malformed, ambiguous, or version-inconsistent.

## What it checks

- Policy status and expiry.
- Dataset reference.
- Exact policy version.
- Declared purpose.
- Declared actor role.
- Presence of an authority-decision reference.

## What it does not establish

- That the referenced decision is authentic, legitimate, current, or authorised.
- That a person or role has been authenticated.
- That a purpose label accurately describes real-world activity.
- That community authority, consent, benefit-sharing, or legal obligations are satisfied.
- That a downstream system actually enforces the returned decision.
- That data cannot be copied, exported, or used outside the calling system.
- Conformance to GA4GH DUO, GA4GH Passports, ODRL, or any other standard.

The field names and decision codes are provisional demonstration choices, not a new standard or ontology. Any standards mapping must be reviewed against the relevant specification and approved by a future host.

## Safety and integration boundary

- Do not connect this prototype to Aidora production, SRHIN systems, or any external data source.
- Do not add real health, mental-health, refugee, participant, or other sensitive data.
- Do not treat `ALLOW` as legal permission or proof of valid consent.
- A production system would need authenticated, authoritative policy retrieval; revocation propagation; tamper-evident audit design; security review; human escalation; accessibility and community governance; and independent testing.
- The caller must fail closed if the evaluator is unavailable or returns an unrecognised response.

## Why this exists

This prototype is a deliberately small, reversible engineering probe. It can be discarded if host-led discovery shows that existing SRHIN processes or tools already solve the relevant problem, or that a software intervention would be inappropriate.
