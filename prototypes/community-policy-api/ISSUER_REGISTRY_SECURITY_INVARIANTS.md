# Issuer Registry Security Invariants

**Status:** proposed security contract; design-only.  
**Scope:** isolated synthetic community-policy API prototype.  
**Related documents:** `ISSUER_GOVERNANCE_DESIGN.md`, `ISSUER_REGISTRY_THREAT_MODEL.md`, and `ISSUER_REGISTRY_DATA_MODEL.md`.  
**Last updated:** 2026-11-24.

## 1. Purpose and safety boundary

This document states properties that a future synthetic issuer-registry implementation must preserve across storage, state transitions, snapshot publication, and verification. It is intended to make security requirements testable and to prevent implementation details from silently weakening the governance design.

These invariants do not establish a real community mandate, identify legitimate authorities, or authorize a real deployment. All fixtures, actors, issuers, mandates, keys, approvals, and snapshots must remain synthetic. No production Aidora backend, SRHIN service, real participant data, or external authority is in scope.

An invariant is a required property, not evidence that the current prototype already enforces it. The current prototype does not implement the registry described by the related design documents.

## 2. Terminology and decision semantics

- **Trust input:** any issuer, mandate, key, registry snapshot, audience, revocation, or approval-status fact required by a verification policy.
- **Protected transition:** a state or authority change requiring authenticated actor authorization and, where policy requires, independent approval.
- **Effective time:** the time at which a decision or status change is defined to take effect.
- **Decision point:** the transactionally defined instant at which the verifier evaluates all required trust inputs and use/revocation state.
- **Non-ALLOW:** a safe outcome such as REJECT or REVIEW. The exact public response vocabulary is an implementation/API decision; uncertainty must never be converted to ALLOW.
- **Immutable identifier:** an identifier that is never reassigned to another logical entity, even after expiry, revocation, or retirement.

Where a rule depends on a governance decision not yet made, implementation must expose an explicit configuration or unresolved-policy state; developers must not invent the missing authority rule.

## 3. Core invariants

### Identity and authority

**INV-01 — Unique immutable identity**  
Every issuer, mandate, approval, transition event, and registry has a stable unique identifier. Identifiers are never reassigned to a different entity. Key IDs are globally unique and never reused.

**INV-02 — Cryptographic proof is not mandate proof**  
A valid signature proves that the corresponding private key signed the signed bytes. It does not establish issuer identity, community legitimacy, mandate validity, or authority for the requested action. Those are independently verified trust inputs.

**INV-03 — Issuer-to-mandate binding**  
Every mandate references exactly one existing issuer. A mandate is evaluated only for that issuer. A mandate cannot be transferred to another issuer by editing its issuer reference.

**INV-04 — Issuer-to-key binding**  
Every key record references exactly one issuer. Verification must reject a key whose registered issuer binding differs from the issuer claimed by the evidence or mandate being evaluated.

### Scope and validity

**INV-05 — Least-authority scope**  
An issuer may act only within the intersection of its active recognition, active mandate, registered key permissions (if constrained), signed approval claims, and relying-party policy. No layer may widen another layer's scope.

**INV-06 — Explicit purpose, action, context, and audience**  
Every verification decision checks the requested purpose, action, context, and applicable subject/domain scope against the active mandate. If audience binding is required, the audience must be present in signed claims and match the verifier's configured audience. Missing or mismatched required audience is non-ALLOW.

**INV-07 — Validity interval required for activation**  
Before an issuer, mandate, or key can become ACTIVE, the applicable effective-start value must be present and valid. The expiry policy must be explicit: either a finite end time or a governance-approved open-ended validity rule. Comparisons use UTC instants and one documented boundary convention. Clock tolerance must be explicit and risk-approved; it must not be guessed in code.

**INV-08 — Parent validity bounds child validity**  
An active mandate's validity interval must not exceed the issuer's recognized authority interval. A key's activation and use must be bounded by the issuer's active recognition and any applicable key-specific validity policy. A child record cannot remain usable after a required parent authority expires, is suspended, or is revoked.

**INV-09 — No implicit scope expansion**  
Any change that broadens issuer recognition, mandate scope, permitted action/purpose/context, or audience requires a new version and the prescribed independent review/approval. Metadata updates must not mutate the meaning of an already approved version.

### Lifecycle and administrative authorization

**INV-10 — Legal state transitions only**  
Every state change must be an allowed edge in the relevant state machine. Direct status-field updates that bypass transition validation are prohibited. Invalid transitions are rejected without partial writes.

**INV-11 — Terminal states are terminal**  
REVOKED and EXPIRED records cannot be reactivated by changing status or extending dates. A new recognition, mandate, or key-registration process must create a new record/identifier, with an explicit successor link where appropriate.

**INV-12 — Independent authorization for protected actions**  
Every protected transition is initiated by an authenticated principal whose authorization is evaluated by a separately controlled authorization policy. Caller-supplied role strings, actor IDs, or approval references are not proof of authorization.

**INV-13 — No self-approval**  
A requester cannot approve their own protected change. Where a reviewer is required, reviewer and approver independence must follow an explicitly configured operation policy. The synthetic test profile must exercise distinct requester/reviewer/approver identities for high-impact actions; this test profile does not decide real-world governance quorum or representation.

**INV-14 — Approval bound to exact change**  
An administrative approval is bound to the exact target record, requested action, canonical request digest, and expected record version. It cannot be replayed for a different payload, action, record, or later version.

### Keys and cryptographic separation

**INV-15 — Private-key exclusion**  
Issuer and registry private keys, seed material, recovery secrets, and signing credentials must never be stored in registry records, snapshots, fixtures, logs, or repository content.

**INV-16 — Separate signing trust domains**  
Issuer signing keys and registry snapshot signing keys are distinct key domains with separate identifiers, custody, authorization, rotation, and compromise procedures. An issuer key must never authorize registry snapshots, and a registry key must never impersonate an issuer.

**INV-17 — Key immutability and proof of possession**  
Once a key is activated, its public-key bytes, fingerprint, algorithm, and issuer binding are immutable for that key ID. Activation requires verified proof of possession and independent registration authorization. Rotation creates a new key ID.

**INV-18 — Compromise is non-reversible**  
A COMPROMISED key cannot return to ACTIVE. Evidence signed during a suspected compromise interval is assessed under an explicit incident policy; signature validity alone is insufficient.

### Registry snapshots and anti-rollback

**INV-19 — Complete authenticated snapshot**  
A snapshot signature and content hash cover all trust-relevant metadata: registry identity, version, issue/expiry times, schema version, previous-version linkage, and canonical content containing the issuer/mandate/key records and versions used for trust decisions. The canonical serialization and hash algorithm must be specified and versioned.

**INV-20 — Monotonic verifier high-water mark**  
For each verifier and registry identity, the highest accepted version and its snapshot hash are durably tracked. A lower version is rejected. The same version with a different hash is an integrity incident and is non-ALLOW.

**INV-21 — Recovery cannot silently roll back trust**  
Restoring an old application database or backup must not silently lower the verifier's trusted high-water mark. Recovery requires a separately protected checkpoint or an explicitly authorized re-bootstrap procedure with audit evidence. If the high-water mark cannot be trusted, verification is non-ALLOW until trust is re-established.

**INV-22 — Freshness and signer trust are mandatory**  
A snapshot must have a valid signature from a currently trusted registry signing key, be within its approved freshness interval, and satisfy the configured clock policy. Initial trust-anchor bootstrap, rotation, emergency compromise, and recovery must be explicitly defined before implementation. An unknown or compromised snapshot signer is non-ALLOW.

### Transactions, revocation, and audit

**INV-23 — Atomic protected transition**  
The state update, record-version increment, required administrative-approval consumption, and transition event commit atomically as one logical operation. A failed step leaves no partially applied transition.

**INV-24 — Optimistic concurrency**  
A protected update succeeds only when the stored record version equals the request's expected prior version. Conflicting concurrent changes cannot both commit against the same prior version. Stale requests must be rejected and re-reviewed.

**INV-25 — Revocation has a defined decision boundary**  
Approval revocation, key suspension/revocation, and mandate suspension/revocation are distinct operations. The system defines a linearization point for each. A verification decision whose decision point is after the revocation's effective time must not return ALLOW based on stale status.

**INV-26 — One-time use is atomic**  
Where an approval is single-use or otherwise consumption-limited, checking and consuming it is atomic with the protected operation. Two concurrent requests cannot both consume the same single-use approval successfully.

**INV-27 — Append-only transition history**  
Every accepted protected transition creates an attributable event with actor, authorization/approval reference, prior and resulting versions, effective and recorded times, and a controlled reason code. Application actors cannot update or delete events. Independent checkpoints, backup, and recovery are required before treating audit history as tamper-evident.

### Safe verification and privacy

**INV-28 — Fail closed on uncertainty**  
Missing, malformed, stale, conflicting, expired, revoked, unauthorized, or unverifiable required trust inputs never produce ALLOW. Registry outage or partition must follow the approved freshness/availability policy; after its permitted bound, return non-ALLOW.

**INV-29 — No sensitive-data overcollection**  
Registry records and transition events store opaque references and controlled reason codes rather than identity documents, personal narratives, raw tokens, private keys, or unnecessary participant data. Access, retention, correction, and disclosure rules must be separately reviewed.

**INV-30 — Synthetic-only boundary**  
Tests and development fixtures use clearly synthetic identities, organizations, mandates, keys, approvals, and content. No real issuer or community authority is represented as registered or approved by this prototype.

## 4. Synthetic operation-policy profile

The following is a test profile for exercising separation of duties, not a proposed real governance constitution:

| Protected operation | Synthetic test expectation |
|---|---|
| Issuer activation | Requester and approver are distinct; independent reviewer is exercised in tests. |
| Mandate activation or scope expansion | Requester, reviewer, and approver are distinct in the strict test case; approval binds to exact scope digest/version. |
| Key activation or rotation | Requester differs from independent registrar/approver; proof of possession is required. |
| Registry signing-key bootstrap/rotation | Separate registry trust-anchor authorization path; no issuer key or issuer administrator can authorize it solely by virtue of issuer status. |
| Suspension/revocation | Authorized actor and effective time are recorded; emergency path, if any, is separately specified and audited. |

Production cardinality, quorum, representation, appeals, and emergency authority remain unresolved governance decisions. The synthetic profile must not be presented as community-approved policy.

## 5. Required unresolved decisions before implementation

These decisions must be answered by accountable governance/security owners rather than inferred by developers:

1. Which validity fields are mandatory, and is open-ended validity ever permitted?
2. What exact interval convention applies at the start/end boundary, and what clock tolerance is acceptable?
3. What exact canonical serialization, hash algorithm, and snapshot schema-versioning policy apply?
4. Does previous-version linkage include only a sequence number or also the prior snapshot hash?
5. Where is each verifier's high-water mark stored, protected, checkpointed, and recovered?
6. How is the registry signing trust anchor initially provisioned, rotated, revoked, and recovered after compromise?
7. Which operation classes require reviewer and approver roles, and what independence/quorum rules apply?
8. What consistency guarantee and decision-point semantics govern suspension, revocation, and one-time consumption?
9. What historical-evidence policy applies after key compromise or mandate withdrawal?
10. What privacy classification, access, retention, correction, and appeal requirements apply?

An unanswered item is an implementation blocker for the affected capability, not permission to select a convenient default.

## 6. Invariant-to-test traceability

These are required future synthetic tests; none is claimed to exist or pass today.

| Test ID | Invariant(s) | Test scenario | Expected result |
|---|---|---|---|
| INV-T01 | 01, 03, 04 | Duplicate identifier or cross-issuer mandate/key binding | Reject |
| INV-T02 | 02 | Valid signature with absent/invalid mandate evidence | Non-ALLOW |
| INV-T03 | 05, 06, 09 | Out-of-scope action or unapproved audience/scope expansion | Reject |
| INV-T04 | 07, 08 | Missing start time, expired parent, or child validity beyond parent | Reject activation/use |
| INV-T05 | 10, 11 | Illegal transition or attempted terminal-state reactivation | Reject |
| INV-T06 | 12, 13 | Unauthorized actor or requester self-approval | Reject and audit |
| INV-T07 | 14 | Reuse approval with changed digest/action/version | Reject |
| INV-T08 | 15, 16 | Private-key material in registry or cross-domain signing-key substitution | Reject fixture/build or verification |
| INV-T09 | 17, 18 | Mutated active key material or compromised key use | Reject |
| INV-T10 | 19 | Modify trust-relevant snapshot metadata/content without valid signature | Reject |
| INV-T11 | 20 | Lower snapshot version or same version with different hash | Reject and raise integrity event |
| INV-T12 | 21 | Restore stale backup with lower high-water mark | Block trust decisions pending recovery |
| INV-T13 | 22 | Unknown signer, expired snapshot, or unapproved trust-anchor rotation | Non-ALLOW |
| INV-T14 | 23, 24 | Inject failure during transition or race two updates on same version | Atomic rollback; at most one commit |
| INV-T15 | 25 | Revocation races with verification | No ALLOW after effective revocation decision point |
| INV-T16 | 26 | Concurrent consumption of one single-use approval | Exactly one successful consumption |
| INV-T17 | 27 | Attempt to alter/delete transition history | Reject; detect integrity discrepancy |
| INV-T18 | 28 | Missing registry/status service beyond approved freshness bound | Non-ALLOW |
| INV-T19 | 29 | Sensitive narrative or private credential in registry/event payload | Reject or redact before persistence |
| INV-T20 | 30 | Real-looking or externally sourced identity/authority fixture | Reject fixture; synthetic-only tests remain isolated |

Each test should assert both the returned decision and the persistent side effects (or absence of side effects), including audit events and record versions.

## 7. Implementation exit criteria

A future schema or code PR may begin only when:

- The cross-document review findings affecting the target capability are resolved or explicitly marked out of scope.
- Every invariant has an identified enforcement layer (database constraint, domain service, cryptographic verifier, authorization policy, transaction boundary, or operational control).
- Every applicable invariant has at least one negative test and, where relevant, a positive control test.
- Snapshot canonicalization, signer trust bootstrap, high-water-mark durability, and recovery behavior are specified before snapshot verification is implemented.
- Revocation and consumption decision-point semantics are specified before concurrent verification/use is implemented.
- The test profile remains synthetic and cannot be mistaken for a real authority configuration.
- No implementation is represented as production-ready or community-authorized merely because tests pass.

The documents and passing synthetic tests can demonstrate consistency of an engineering prototype only. They cannot establish legitimacy, consent, or authorization for real-world use.
