# Issuer Registry Data Model

**Status:** proposed logical data model; design-only.  
**Scope:** isolated synthetic community-policy API prototype.  
**Related documents:** ISSUER_GOVERNANCE_DESIGN.md and ISSUER_REGISTRY_THREAT_MODEL.md.  
**Last updated:** 2026-11-24.

## 1. Purpose and boundary

This document defines a logical data model for a future synthetic issuer registry. It describes records, relationships, integrity constraints, and transaction expectations. It does not implement database tables, API endpoints, administrative permissions, real issuer registration, or production integrations.

All examples and test fixtures must use synthetic identifiers and data. This model does not establish that Aidora, its developers, SRHIN, or any other organization has a community mandate or authority to issue approvals. Real deployment would require separate governance, safeguarding, privacy, legal, and security review.

The current prototype's existing approval/key/revocation components are not equivalent to this proposed registry. In particular, the current operator-configured Ed25519 keyring is not an authoritative issuer/mandate registry.

## 2. Design principles

1. Separate authority from cryptography. A valid signature proves possession of a signing key; it does not prove that the issuer has a legitimate mandate.
2. Separate issuer keys from registry keys. Issuer signing keys sign approval evidence. A distinct registry signing key signs registry snapshots. Compromise of one must not confer the other's authority.
3. Keep records versioned. Material changes create new versions and append-only events; do not silently overwrite authority-bearing facts.
4. Enforce state transitions centrally. A status field cannot be changed without validating the transition, actor authorization, required approvals, and record version.
5. Minimize sensitive data. Store references to protected evidence rather than duplicating identity documents or sensitive narratives in ordinary registry records.
6. Fail closed. Missing, stale, conflicting, or unverifiable trust inputs must never produce ALLOW.
7. Use synthetic-only fixtures. No real names, organizations, personal documents, keys, mandates, or participant records in this prototype.

## 3. Conceptual entities

- IssuerRecord: identity and lifecycle state of a proposed issuer.
- MandateRecord: bounded authority granted to an issuer.
- KeyRecord: public-key metadata bound to an issuer and intended use.
- RegistrySnapshot: authenticated, versioned representation of registry state.
- TransitionEvent: append-only record of a state transition.
- AdministrativeApproval: evidence that a sensitive administrative change received the required independent decision.
- RegistryActor (reference): authenticated administrative principal and its externally managed authorization reference. This model does not itself grant roles.

Approval evidence issued to a subject remains a separate domain object. A future verifier may reference issuer, mandate, key, and registry versions used in its decision, but this document does not change the current approval token format.

## 4. Entity definitions

### 4.1 IssuerRecord

| Field | Logical type | Required | Notes |
|---|---|---:|---|
| issuer_id | UUID | Yes | Immutable primary identifier. |
| display_name | String | Yes | Synthetic display label in this prototype. |
| identity_evidence_ref | Opaque reference | Yes | Pointer to separately protected evidence; not the evidence itself. |
| governance_decision_ref | Opaque reference | At activation | Reference to independently reviewed recognition decision. |
| status | Enum | Yes | PENDING, UNDER_REVIEW, ACTIVE, SUSPENDED, REVOKED, EXPIRED. |
| effective_from | Timestamp | No | Start of recognized period. |
| effective_until | Timestamp | No | End of recognized period, if time-bounded. |
| record_version | Positive integer | Yes | Monotonically increasing per issuer. |
| created_at | Timestamp | Yes | Creation time. |
| updated_at | Timestamp | Yes | Last material update time. |

Constraints:
- issuer_id is immutable and unique.
- Activation requires a valid governance decision reference and required independent approvals.
- REVOKED and EXPIRED are terminal for that record; a new recognition process creates a new issuer record or formally approved successor relationship, never silent reactivation.
- A display-name change does not change issuer identity and must be versioned and audited.
- Do not store personal identity documents or sensitive community narratives in this record.

### 4.2 MandateRecord

| Field | Logical type | Required | Notes |
|---|---|---:|---|
| mandate_id | UUID | Yes | Immutable primary identifier. |
| issuer_id | UUID | Yes | Foreign key to IssuerRecord. |
| scope | Structured JSON | Yes | Explicit subject/domain/context constraints. |
| permitted_purposes | Array | Yes | Allowlisted purposes. |
| permitted_actions | Array | Yes | Allowlisted actions. |
| permitted_contexts | Array | Yes | Allowlisted contexts. |
| audiences | Array | Conditional | Required when approvals are relying-party-specific. |
| decision_reference | Opaque reference | Yes before approval | Reference to the decision and its evidence. |
| status | Enum | Yes | DRAFT, SUBMITTED, APPROVED, ACTIVE, SUSPENDED, REVOKED, EXPIRED. |
| effective_from | Timestamp | No | Start of mandate. |
| effective_until | Timestamp | No | Expiry of mandate. |
| record_version | Positive integer | Yes | Monotonically increasing per mandate. |
| created_at | Timestamp | Yes | Creation time. |
| updated_at | Timestamp | Yes | Last material update time. |

Constraints:
- issuer_id must reference an existing issuer.
- An active mandate cannot exceed the issuer's recognized authority period.
- A mandate is valid only for its explicitly listed purposes, actions, contexts, scope, and—where required—audiences.
- Scope expansion is a new, independently approved version; it is not an ordinary metadata edit.
- An issuer may have multiple mandates, but each mandate is independently evaluated.
- REVOKED and EXPIRED are terminal for that mandate record.

### 4.3 KeyRecord

| Field | Logical type | Required | Notes |
|---|---|---:|---|
| key_id | Non-empty immutable string | Yes | Globally unique; never reused. |
| issuer_id | UUID | Yes | Foreign key to IssuerRecord. |
| algorithm | Enum/string | Yes | Explicit allowlist; current prototype uses Ed25519 for approval signing. |
| public_key_fingerprint | String | Yes | Canonical fingerprint of public-key bytes. |
| public_key_material or public_key_ref | Bytes/reference | Yes | Public material only; private key must never enter Registry. |
| proof_of_possession_ref | Opaque reference | Before activation | Evidence that registrant controls corresponding private key. |
| status | Enum | Yes | GENERATED, PENDING_REGISTRATION, ACTIVE, SUSPENDED, COMPROMISED, REVOKED, EXPIRED, RETIRED. |
| registered_at | Timestamp | No | Registration time. |
| activated_at | Timestamp | No | Activation time. |
| effective_until | Timestamp | No | Expiry, if configured. |
| record_version | Positive integer | Yes | Monotonically increasing per key record. |

Constraints:
- key_id is globally unique and never reused, including after retirement or revocation.
- An activated key's public-key bytes and fingerprint are immutable. Rotation creates a new key ID and a linked event.
- A key must be bound to exactly one issuer in a given record version.
- Activation requires proof of possession and independent registration approval.
- A COMPROMISED key cannot return to ACTIVE; compromise triggers review of evidence from the possible compromise interval.
- Private keys, recovery secrets, and signing credentials are prohibited from this data model.

### 4.4 RegistrySnapshot

| Field | Logical type | Required | Notes |
|---|---|---:|---|
| registry_id | UUID | Yes | Stable identifier for this registry authority. |
| version | Positive integer | Yes | Strictly monotonic registry version. |
| issued_at | Timestamp | Yes | Snapshot creation time. |
| expires_at | Timestamp | Yes | End of permitted freshness interval. |
| previous_version | Positive integer/null | Yes | Previous version; null only for genesis snapshot. |
| content_hash | String | Yes | Hash of canonical snapshot content. |
| signature | Bytes/string | Yes | Signature made by registry signing key, not issuer key. |
| registry_signing_key_id | String | Yes | Identifies the registry-signing public key. |
| schema_version | String | Yes | Snapshot schema version. |

Constraints:
- Registry signing key is separate from all issuer signing keys and separately governed.
- Snapshot signature covers registry ID, version, issue/expiry times, previous-version reference, schema version, and content hash.
- Verifiers persist a trustworthy high-water mark and reject any lower version.
- Duplicate version with different content hash is a registry integrity incident.
- Expired, unverifiable, conflicting, or stale snapshots cannot produce ALLOW.
- Freshness duration, clock tolerance, recovery behavior, and trust-anchor distribution remain governance/security decisions; do not hard-code arbitrary values in the prototype design.

### 4.5 TransitionEvent

| Field | Logical type | Required | Notes |
|---|---|---:|---|
| event_id | UUID | Yes | Immutable unique event ID. |
| record_type | Enum | Yes | ISSUER, MANDATE, KEY, or other explicitly supported type. |
| record_id | UUID/string | Yes | Target record identifier. |
| previous_state | String/null | Yes | State before transition. |
| new_state | String | Yes | State after transition. |
| actor_id | Stable principal reference | Yes | Authenticated actor, not caller-supplied free text. |
| approval_id | UUID/null | Conditional | Required for transitions needing independent approval. |
| decision_reference | Opaque reference | Conditional | Reference to underlying decision. |
| effective_at | Timestamp | Yes | When transition takes effect. |
| recorded_at | Timestamp | Yes | When event was committed. |
| prior_record_version | Positive integer | Yes | Expected previous version. |
| resulting_record_version | Positive integer | Yes | New version. |
| reason_code | Controlled enum | Yes | Minimize sensitive free-text content. |
| integrity_metadata | Structured reference | Yes | Link to independent integrity/checkpoint mechanism when implemented. |

Constraints:
- Events are append-only; updates/deletes are prohibited to application actors.
- A transition must validate the expected prior version and legal state edge.
- Concurrent transitions using the same prior version cannot both commit.
- Actor authorization must be resolved against an independent authorization service/policy.
- A role label or actor ID alone is not proof of authorization.
- Sensitive narratives and identity documents must not be copied into event payloads.

### 4.6 AdministrativeApproval

| Field | Logical type | Required | Notes |
|---|---|---:|---|
| approval_id | UUID | Yes | Immutable primary identifier. |
| target_record_type | Enum | Yes | ISSUER, MANDATE, KEY, REGISTRY_CONFIG, etc. |
| target_record_id | UUID/string | Yes | Record being changed. |
| requested_action | Controlled enum | Yes | Exact proposed operation. |
| requester_id | Stable principal reference | Yes | Authenticated requester. |
| reviewer_id | Stable principal reference | Conditional | Independent reviewer, if required. |
| approver_id | Stable principal reference | Conditional | Authorized decision-maker. |
| decision | Enum | Yes | PENDING, APPROVED, REJECTED, WITHDRAWN. |
| decision_reference | Opaque reference | Conditional | Evidence/reference for decision. |
| created_at | Timestamp | Yes | Request time. |
| decided_at | Timestamp | Conditional | Decision time. |
| target_record_version | Positive integer | Yes | Version the decision applies to. |
| request_digest | String | Yes | Binds approval to exact proposed change. |

Constraints:
- Approval binds to the exact target record, action, request digest, and expected record version.
- Requester cannot approve their own protected change.
- Reviewer and approver independence requirements are policy-controlled and enforced server-side.
- A decision cannot be reused for a different request digest or later record version.
- Approval evidence does not itself confer an administrative role; authorization is checked separately.

### 4.7 RegistryActor reference

The registry may store stable references to authenticated principals, but authoritative identity, authentication factors, role assignment, and authorization policy belong to a separately controlled identity/access-management system.

Minimum reference attributes, if needed:
- stable principal ID;
- authentication issuer/reference;
- account status reference;
- authorization decision reference;
- audit correlation ID.

Do not store passwords, recovery codes, private credentials, or assume that a user-supplied role string grants permission.

## 5. Relationships

```
IssuerRecord 1 -------- many MandateRecord
IssuerRecord 1 -------- many KeyRecord

RegistrySnapshot 1 ---- many snapshot record references
IssuerRecord 1 -------- many TransitionEvent
MandateRecord 1 ------- many TransitionEvent
KeyRecord 1 ----------- many TransitionEvent

AdministrativeApproval 1 ---- 1 exact proposed change
TransitionEvent 0..1 --------- 1 AdministrativeApproval

Verifier decision -------- references:
  issuer_id + issuer_record_version
  mandate_id + mandate_record_version
  key_id + key_record_version
  registry_id + registry_version
  audience
  approval evidence ID / consumption reference
```

A registry snapshot is a consistent view of a registry version, not an independent authority source. A verifier decision should retain enough version references to explain which state was evaluated.

## 6. Cross-record integrity rules

The following checks must be evaluated together at the defined verification decision point:

1. Issuer exists, is ACTIVE, and is within its effective period.
2. Mandate exists, belongs to that issuer, is ACTIVE, and is within its effective period.
3. Requested purpose, action, context, subject/domain scope, and required audience are inside the mandate.
4. Key exists, belongs to the same issuer, is ACTIVE, and is within its effective period.
5. Key algorithm is explicitly allowed and signature verifies against the registered public key.
6. Registry snapshot is authentic, current, unexpired, consistent, and not below the verifier's high-water mark.
7. Approval evidence is valid, unexpired, unrevoked, and not already consumed beyond its permitted use.
8. Required audience is present in signed claims and matches verifier configuration.
9. Any required administrative approval binds to the exact record version and proposed change.
10. Any missing, stale, contradictory, or unverifiable input produces a non-ALLOW outcome.

An ACTIVE issuer does not make every mandate valid. An ACTIVE mandate does not make every key valid. A valid signature does not prove a valid mandate. These are independent checks.

## 7. Transaction and concurrency expectations

- Sensitive changes use optimistic concurrency: update only if the stored record version equals the request's expected version.
- State transition, record version increment, transition event, and associated approval consumption must commit atomically where they form one logical operation.
- One-time approval consumption must be atomic with the protected operation.
- Registry snapshot publication must represent one consistent committed registry version.
- If concurrent updates conflict, reject one and require a fresh review against the latest version; do not silently merge authority-bearing fields.
- Revocation semantics must define a linearization point. A verifier must not return ALLOW for a decision point after revocation is effective.
- During partition or unavailable status service, cached data may be used only within an explicitly approved freshness bound; after that bound, fail closed.

## 8. Storage and implementation guidance

For an isolated prototype, SQLite may be used to explore schemas and transactions, but this does not establish production suitability or distributed consistency.

Recommended logical storage choices:
- UUID primary keys for issuer, mandate, approval, and event records.
- Unique, never-reused string key IDs.
- Foreign-key enforcement for issuer/mandate/key relationships.
- Strict schema validation for structured scope and audience data.
- Controlled enums for lifecycle states and reason codes.
- Append-only transition events, protected by independent checkpoints when implemented.
- Separate protected evidence storage referenced by opaque IDs.
- Separate registry signing-key custody and issuer signing-key custody.

Do not put secrets or real identity evidence in fixtures, source control, logs, test snapshots, or generated documentation.

## 9. Integrity constraints checklist

| ID | Constraint |
|---|---|
| C01 | Issuer IDs are unique and immutable. |
| C02 | Mandates reference an existing issuer. |
| C03 | Keys reference an existing issuer. |
| C04 | Key IDs are globally unique and never reused. |
| C05 | Activated public-key material cannot be silently changed. |
| C06 | Mandate validity cannot exceed issuer authority validity. |
| C07 | Requested action, purpose, context, scope, and required audience must fit the mandate. |
| C08 | Terminal issuer/mandate/key states cannot be reactivated by direct status edit. |
| C09 | Protected administrative changes require independent authorization and approval. |
| C10 | Registry snapshots are signed, versioned, time-bounded, and rollback-protected. |
| C11 | Transition events are append-only and version-checked. |
| C12 | A failed or indeterminate trust check never returns ALLOW. |
| C13 | Issuer and registry signing keys are separate trust domains. |
| C14 | Approval decisions bind to exact request digest and record version. |
| C15 | Snapshot content hash and signature cover all trust-relevant metadata. |
| C16 | Revocation and one-time consumption follow a documented atomicity contract. |

## 10. Mapping to the threat model

| Data-model element | Primary threat coverage |
|---|---|
| IssuerRecord and governance references | T01, T02, T13, T14 |
| MandateRecord and scope constraints | T02, T03 |
| KeyRecord, proof of possession, immutable key ID | T04, T05, T06, T07 |
| RegistrySnapshot and high-water mark | T08, T09, T10, T12 |
| TransitionEvent and version checks | T11, T15, T16 |
| AdministrativeApproval and actor references | T01, T13, T14, T15 |
| Privacy separation and opaque evidence references | T17 |
| Freshness and outage rules | T09, T12, T18 |
| Approval references and atomic consumption | T11, T19 |
| Audience field and verifier binding | T03, T20 |

The model supports the proposed ST01–ST20 security tests in ISSUER_REGISTRY_THREAT_MODEL.md; it does not claim those tests have been implemented or passed.

## 11. Decisions required before schema implementation

The following must be decided by accountable governance/security owners, not guessed by developers:

1. Which body or process can recognize an issuer and approve a mandate?
2. What independent evidence is sufficient, and who can inspect it?
3. Which changes require one, two, or more independent approvals?
4. What exact scope vocabulary and audience model are supported?
5. Who operates and governs the registry signing key?
6. What snapshot freshness bound, clock tolerance, and trust-anchor distribution are acceptable?
7. What consistency/linearization contract applies to suspension and revocation?
8. How are historical approvals assessed after key compromise or mandate revocation?
9. What evidence is public, restricted, or retained only in a protected evidence store?
10. What are the recovery, backup, audit-checkpoint, and incident-response responsibilities?

No implementation should invent answers to these governance questions.

## 12. Acceptance criteria

This document is ready for design review when reviewers can:
- trace every record and relationship to a governance requirement or threat;
- distinguish issuer signing authority from registry snapshot authority;
- identify all sensitive data and confirm it is minimized or externally protected;
- verify that scope, state, version, and audience constraints are explicit;
- identify the atomic transaction boundaries for transition, revocation, and consumption;
- map each threat-model test to data-model constraints;
- identify unresolved governance decisions without treating them as implementation defaults.

A subsequent implementation proposal should add schema migrations and synthetic fixtures only after review. It must remain isolated from production Aidora, SRHIN, real community authorities, real people, and sensitive datasets unless a separate, explicit authorization and safety review approves a change in scope.
