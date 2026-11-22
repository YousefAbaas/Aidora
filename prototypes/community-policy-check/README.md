# Synthetic community-policy check — reference prototype

**Status:** experimental reference code for discussion only. It is not an SRHIN integration, not a production access-control system, and not a standards-conformant GA4GH or ODRL implementation.

This prototype exists to make one narrow engineering idea inspectable: a downstream service can refuse to return ALLOW unless a policy is active, the requested purpose and action are explicitly permitted, required approvals are present, and required context conditions match.

## What it demonstrates

- Three explicit outcomes: `ALLOW`, `DENY`, and `REVIEW`.
- Fail-closed behaviour for malformed, expired, duplicate/conflicting, or unrecognised approval inputs; explicit DENY takes precedence over approvals and REVIEW flags.
- Version and reason-code traceability in the response.
- A small, deterministic core that can be tested with Python's standard library.
- Synthetic inputs only; no names, participant IDs, clinical narratives, or real host policy.

## What it does not demonstrate

- It does not prove that a community decision is legitimate or that an approval was issued by a person with proper authority.
- It does not authenticate researchers, verify signatures, manage identities, store consent, enforce contracts, or control data outside a system that invokes it.
- It does not implement DUO, GA4GH Passports, Data Passports, ODRL, or any SRHIN API.
- It does not decide whether any data use is lawful or ethically approved.
- It does not create a new governance process or replace human/community decision-making.

## Run the tests

From this directory, run:

```bash
python -m unittest -v
```

No third-party packages are required.

## Example

```python
from datetime import datetime, timezone
from policy_check import evaluate_policy

policy = {
    "policy_id": "synthetic-policy-001",
    "version": "0.1",
    "status": "active",
    "effective_from": "2027-01-01T00:00:00+00:00",
    "expires_at": "2027-12-31T23:59:59+00:00",
    "allowed_purposes": ["synthetic_method_validation"],
    "denied_purposes": ["commercial_model_training"],
    "allowed_actions": ["run_aggregate_test"],
    "denied_actions": ["export_row_level_data"],
    "required_approvals": ["community_governance", "data_steward"],
    "required_context": {"environment": "approved_sandbox"},
    "review_required": False,
}

request = {
    "purpose": "synthetic_method_validation",
    "action": "run_aggregate_test",
    "approvals": [
        {"type": "community_governance", "status": "approved", "reference": "synthetic-ref-a"},
        {"type": "data_steward", "status": "approved", "reference": "synthetic-ref-b"},
    ],
    "context": {"environment": "approved_sandbox"},
}

result = evaluate_policy(
    policy,
    request,
    now=datetime(2027, 3, 1, tzinfo=timezone.utc),
)
print(result["decision"])  # ALLOW
```

The references above are fake placeholders. A real implementation would require an approved trust model and verifiable evidence; a string reference is not proof of approval. Adversarial tests intentionally demonstrate that this prototype still trusts caller-supplied policy objects and non-empty approval-reference strings: an attacker able to alter those inputs can manufacture an ALLOW. These are documented prototype limitations, not acceptable production behaviour.

## Adversarial test coverage

The negative tests cover duplicate/conflicting approval records, expiry boundaries and malformed expiry values, explicit DENY precedence, and REVIEW precedence. Two tests deliberately expose unresolved trust-boundary weaknesses: fabricated approval references and caller-modified policy objects. The expected ALLOW in those tests is a warning that this function is not a security boundary. A future design would need a trusted policy registry, immutable/version-pinned policy retrieval, authenticated and verifiable approval evidence, and a separately reviewed enforcement boundary.

## Design rule

An `ALLOW` response is only a local decision by this function. The calling system must enforce it at the exact data-access boundary, protect the policy and inputs from tampering, and prevent bypass paths. If those guarantees cannot be made, this component must not be used to protect real data.
