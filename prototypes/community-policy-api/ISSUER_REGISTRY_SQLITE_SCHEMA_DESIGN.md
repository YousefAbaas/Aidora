# Issuer Registry SQLite Schema Design

**Status:** proposed logical/physical schema design; documentation only.  
**Scope:** isolated synthetic community-policy API prototype.  
**Depends on:** `ISSUER_GOVERNANCE_DESIGN.md`, `ISSUER_REGISTRY_THREAT_MODEL.md`, `ISSUER_REGISTRY_DATA_MODEL.md`, and `ISSUER_REGISTRY_SECURITY_INVARIANTS.md`.  
**Last updated:** 2026-11-24.

## 1. Purpose and non-goals

This document translates the existing logical issuer-registry model into a proposed SQLite schema structure, relationship strategy, integrity controls, and transaction boundaries. It is a design artifact only.

It does **not**:
- create or migrate any database;
- add runtime code, endpoints, administrative permissions, or real trust anchors;
- register real issuers, mandates, keys, administrators, or communities;
- connect the registry to production Aidora, SRHIN, or real participant data;
- resolve governance decisions that belong to an accountable host and affected people.

All future fixtures must be synthetic. A database constraint, passing test, signature, or `ALLOW` result is not proof of community legitimacy, informed consent, or legal authority.

## 2. SQLite assumptions and limits

### 2.1 Baseline

The eventual implementation should use a SQLite version supporting:
- foreign-key constraints (enabled on **every** connection);
- partial indexes;
- UPSERT;
- WAL mode if justified by the deployment's concurrency profile;
- `STRICT` tables if the supported SQLite runtime is at least 3.37.0.

If the supported runtime is older, use explicit `typeof(...)` checks and test the exact deployed version. The schema must declare and test its minimum SQLite version rather than silently relying on local developer versions.

Recommended connection initialization, subject to runtime verification:

```sql
PRAGMA foreign_keys = ON;
PRAGMA busy_timeout = 5000;
```

WAL mode is an operational choice, not a security control. It does not provide distributed consensus, independent audit anchoring, or anti-rollback protection.

### 2.2 What SQLite cannot guarantee by itself

SQLite alone cannot:
- provide multi-host consensus or linearizable state across independent database copies;
- stop an operator from replacing the database file with an older backup;
- protect a high-water mark stored only in the same rollback-prone database;
- prove that a named actor is authenticated or authorized;
- protect audit history against a privileged operator who can replace the file and its contents;
- safely resolve governance, quorum, representation, or consent questions.

The verifier's anti-rollback checkpoint therefore requires an independently protected mechanism or a documented, authorized re-bootstrap procedure. A second table in the same SQLite file is **not** an independent checkpoint.

## 3. Proposed table inventory

The design separates stable record identity from immutable versions.

| Table | Purpose | Mutability model |
|---|---|---|
| `issuers` | Stable issuer identity | Insert once; no identity reassignment |
| `issuer_versions` | Versioned issuer attributes and state | Insert new versions; no in-place edits |
| `mandates` | Stable mandate identity and issuer binding | Insert once |
| `mandate_versions` | Versioned scope, audiences, validity, and state | Insert new versions |
| `issuer_keys` | Stable key ID and issuer binding | Insert once; key ID never reused |
| `issuer_key_versions` | Versioned public-key metadata and lifecycle state | Insert new versions; activated key material immutable |
| `administrative_approvals` | Approval of an exact proposed change | Insert/update only while pending under a controlled workflow; terminal decision immutable |
| `transition_events` | Append-only state-transition history | Insert only |
| `registry_snapshots` | Signed, versioned registry snapshot envelope | Insert only |
| `snapshot_issuer_versions` | Issuer versions included in a snapshot | Insert only |
| `snapshot_mandate_versions` | Mandate versions included in a snapshot | Insert only |
| `snapshot_key_versions` | Key versions included in a snapshot | Insert only |
| `verifier_registry_state` | Per-verifier, per-registry accepted high-water mark | Monotonic conditional update |
| `verifier_checkpoint_receipts` | References/receipts for independent checkpoint operations | Append-only references; checkpoint itself is external |

The existing approval-evidence/replay/revocation tables in the current prototype remain separate. This design does not silently replace or reinterpret them.

## 4. Core schema shape

The SQL fragments below are illustrative design fragments, not migration-ready DDL. Exact enum values, timestamp policy, canonical serialization, and unresolved governance rules must be settled before implementation.

### 4.1 Stable identity tables

```sql
CREATE TABLE issuers (
    issuer_id TEXT PRIMARY KEY,
    created_at TEXT NOT NULL
) STRICT;

CREATE TABLE mandates (
    mandate_id TEXT PRIMARY KEY,
    issuer_id TEXT NOT NULL REFERENCES issuers(issuer_id) ON DELETE RESTRICT,
    created_at TEXT NOT NULL,
    UNIQUE (mandate_id, issuer_id)
) STRICT;

CREATE TABLE issuer_keys (
    key_id TEXT PRIMARY KEY,
    issuer_id TEXT NOT NULL REFERENCES issuers(issuer_id) ON DELETE RESTRICT,
    created_at TEXT NOT NULL,
    UNIQUE (key_id, issuer_id)
) STRICT;
```

Design notes:
- IDs should be generated using a vetted UUID strategy or another explicitly specified immutable identifier format.
- Never recycle an issuer ID, mandate ID, or key ID after expiry, revocation, or retirement.
- A mandate and key are permanently bound to the issuer recorded at creation. A transfer requires a new record and fresh review.
- `ON DELETE RESTRICT` is intentional. Authority-bearing records must not disappear through cascading deletion.

### 4.2 Versioned issuer records

```sql
CREATE TABLE issuer_versions (
    issuer_id TEXT NOT NULL REFERENCES issuers(issuer_id) ON DELETE RESTRICT,
    record_version INTEGER NOT NULL CHECK (record_version > 0),
    display_name TEXT NOT NULL,
    identity_evidence_ref TEXT NOT NULL,
    governance_decision_ref TEXT,
    status TEXT NOT NULL CHECK (status IN
      ('PENDING','UNDER_REVIEW','ACTIVE','SUSPENDED','REVOKED','EXPIRED')),
    effective_from TEXT,
    effective_until TEXT,
    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL,
    PRIMARY KEY (issuer_id, record_version),
    CHECK (effective_until IS NULL OR effective_from IS NULL
           OR effective_until > effective_from)
) STRICT;
```

The exact timestamp format and interval boundary convention remain unresolved. Before an issuer version can be treated as ACTIVE, the domain service must enforce the approved effective-period policy, valid governance decision reference, and required independent approvals. A SQL CHECK cannot validate the referenced evidence or prove its authority.

### 4.3 Versioned mandate records

```sql
CREATE TABLE mandate_versions (
    mandate_id TEXT NOT NULL REFERENCES mandates(mandate_id) ON DELETE RESTRICT,
    record_version INTEGER NOT NULL CHECK (record_version > 0),
    scope_json TEXT NOT NULL,
    permitted_purposes_json TEXT NOT NULL,
    permitted_actions_json TEXT NOT NULL,
    permitted_contexts_json TEXT NOT NULL,
    audiences_json TEXT,
    decision_reference TEXT,
    status TEXT NOT NULL CHECK (status IN
      ('DRAFT','SUBMITTED','APPROVED','ACTIVE','SUSPENDED','REVOKED','EXPIRED')),
    effective_from TEXT,
    effective_until TEXT,
    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL,
    PRIMARY KEY (mandate_id, record_version),
    CHECK (effective_until IS NULL OR effective_from IS NULL
           OR effective_until > effective_from)
) STRICT;
```

JSON columns are text at the SQLite storage layer. The application must parse them with a strict schema, reject duplicate/unknown fields where the format requires, normalize values according to a specified canonicalization contract, and validate scope semantics. Do not assume SQLite JSON support is present or that `json_valid()` alone provides semantic validation.

The active mandate version must be bounded by the relevant issuer authority interval. That cross-table temporal rule belongs in a transactionally enforced domain service (and may be supplemented by triggers after the rule is fully specified).

### 4.4 Versioned issuer-key records

```sql
CREATE TABLE issuer_key_versions (
    key_id TEXT NOT NULL REFERENCES issuer_keys(key_id) ON DELETE RESTRICT,
    record_version INTEGER NOT NULL CHECK (record_version > 0),
    algorithm TEXT NOT NULL,
    public_key_fingerprint TEXT NOT NULL,
    public_key_material BLOB,
    public_key_ref TEXT,
    proof_of_possession_ref TEXT,
    status TEXT NOT NULL CHECK (status IN
      ('GENERATED','PENDING_REGISTRATION','ACTIVE','SUSPENDED',
       'COMPROMISED','REVOKED','EXPIRED','RETIRED')),
    registered_at TEXT,
    activated_at TEXT,
    effective_until TEXT,
    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL,
    PRIMARY KEY (key_id, record_version),
    CHECK ((public_key_material IS NOT NULL) <> (public_key_ref IS NOT NULL))
) STRICT;
```

Only public key material or a reference to public material is allowed. Private keys, seeds, recovery secrets, and signing credentials are prohibited. The selected storage mode (inline public bytes versus external public-key reference) must be consistent across a deployment.

Once a key is activated, its algorithm, public-key bytes/reference, fingerprint, and issuer binding are immutable for that key ID. A key rotation creates a new `key_id`. A compromised key can never transition back to ACTIVE.

### 4.5 Administrative approvals

```sql
CREATE TABLE administrative_approvals (
    approval_id TEXT PRIMARY KEY,
    target_record_type TEXT NOT NULL CHECK (target_record_type IN
      ('ISSUER','MANDATE','KEY','REGISTRY_CONFIG')),
    target_record_id TEXT NOT NULL,
    requested_action TEXT NOT NULL,
    requester_principal_ref TEXT NOT NULL,
    reviewer_principal_ref TEXT,
    approver_principal_ref TEXT,
    decision TEXT NOT NULL CHECK (decision IN
      ('PENDING','APPROVED','REJECTED','WITHDRAWN')),
    decision_reference TEXT,
    target_record_version INTEGER NOT NULL CHECK (target_record_version > 0),
    request_digest TEXT NOT NULL,
    created_at TEXT NOT NULL,
    decided_at TEXT,
    CHECK (reviewer_principal_ref IS NULL
           OR reviewer_principal_ref <> requester_principal_ref),
    CHECK (approver_principal_ref IS NULL
           OR approver_principal_ref <> requester_principal_ref)
) STRICT;
```

The polymorphic target reference cannot be protected by a conventional single foreign key. The service must resolve the target table, verify the exact target version, and bind the approval to a canonical request digest. If reviewer/approver cardinality is required, the service must also enforce distinct identities according to the operation policy. The schema's two simple inequality checks do not replace that policy.

Approval terminality, reviewer/approver separation, and whether a reviewer is mandatory are unresolved per-operation policy decisions. The SQL fragment must not be treated as deciding them.

### 4.6 Transition events

```sql
CREATE TABLE transition_events (
    event_id TEXT PRIMARY KEY,
    record_type TEXT NOT NULL CHECK (record_type IN ('ISSUER','MANDATE','KEY')),
    record_id TEXT NOT NULL,
    prior_state TEXT,
    new_state TEXT NOT NULL,
    prior_record_version INTEGER,
    resulting_record_version INTEGER NOT NULL CHECK (resulting_record_version > 0),
    actor_principal_ref TEXT NOT NULL,
    approval_id TEXT REFERENCES administrative_approvals(approval_id)
      ON DELETE RESTRICT,
    decision_reference TEXT,
    effective_at TEXT NOT NULL,
    recorded_at TEXT NOT NULL,
    reason_code TEXT NOT NULL,
    integrity_checkpoint_ref TEXT,
    UNIQUE (record_type, record_id, resulting_record_version)
) STRICT;
```

Because `record_id` is polymorphic, a normal foreign key cannot guarantee its target. The domain service must verify the target and version in the same transaction. Do not add a misleading FK that only protects one record type.

Application code should expose INSERT only for this table. Add defensive UPDATE/DELETE rejection triggers in a later migration if the chosen migration/testing strategy can demonstrate that they do not obstruct controlled maintenance or recovery. Database triggers do not protect against an operator replacing the database file.

### 4.7 Registry snapshots and included versions

```sql
CREATE TABLE registry_snapshots (
    registry_id TEXT NOT NULL,
    version INTEGER NOT NULL CHECK (version > 0),
    issued_at TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    previous_version INTEGER,
    previous_snapshot_hash TEXT,
    content_hash TEXT NOT NULL,
    signature BLOB NOT NULL,
    registry_signing_key_id TEXT NOT NULL,
    schema_version TEXT NOT NULL,
    canonicalization_id TEXT NOT NULL,
    PRIMARY KEY (registry_id, version),
    CHECK (expires_at > issued_at),
    CHECK (previous_version IS NULL OR previous_version < version),
    CHECK ((previous_version IS NULL) = (previous_snapshot_hash IS NULL))
) STRICT;

CREATE TABLE snapshot_issuer_versions (
    registry_id TEXT NOT NULL,
    snapshot_version INTEGER NOT NULL,
    issuer_id TEXT NOT NULL,
    issuer_record_version INTEGER NOT NULL,
    PRIMARY KEY (registry_id, snapshot_version, issuer_id),
    FOREIGN KEY (registry_id, snapshot_version)
      REFERENCES registry_snapshots(registry_id, version) ON DELETE RESTRICT,
    FOREIGN KEY (issuer_id, issuer_record_version)
      REFERENCES issuer_versions(issuer_id, record_version) ON DELETE RESTRICT
) STRICT;

CREATE TABLE snapshot_mandate_versions (
    registry_id TEXT NOT NULL,
    snapshot_version INTEGER NOT NULL,
    mandate_id TEXT NOT NULL,
    mandate_record_version INTEGER NOT NULL,
    PRIMARY KEY (registry_id, snapshot_version, mandate_id),
    FOREIGN KEY (registry_id, snapshot_version)
      REFERENCES registry_snapshots(registry_id, version) ON DELETE RESTRICT,
    FOREIGN KEY (mandate_id, mandate_record_version)
      REFERENCES mandate_versions(mandate_id, record_version) ON DELETE RESTRICT
) STRICT;

CREATE TABLE snapshot_key_versions (
    registry_id TEXT NOT NULL,
    snapshot_version INTEGER NOT NULL,
    key_id TEXT NOT NULL,
    key_record_version INTEGER NOT NULL,
    PRIMARY KEY (registry_id, snapshot_version, key_id),
    FOREIGN KEY (registry_id, snapshot_version)
      REFERENCES registry_snapshots(registry_id, version) ON DELETE RESTRICT,
    FOREIGN KEY (key_id, key_record_version)
      REFERENCES issuer_key_versions(key_id, record_version) ON DELETE RESTRICT
) STRICT;
```

This normalized membership model makes the exact record versions in a snapshot queryable. It does not, by itself, define the canonical bytes that are hashed and signed. Snapshot canonicalization must specify field ordering, UTF-8 handling, JSON normalization, omitted/null semantics, numeric representation, timestamp normalization, and schema evolution before code is written.

The registry signing-key trust anchor is not modeled as an issuer key. Its bootstrap, rotation, compromise, and recovery need a separate trust procedure. The `registry_signing_key_id` is only an identifier, not proof that a verifier trusts that key.

### 4.8 Verifier high-water mark and external checkpoint references

```sql
CREATE TABLE verifier_registry_state (
    verifier_id TEXT NOT NULL,
    registry_id TEXT NOT NULL,
    highest_version INTEGER NOT NULL CHECK (highest_version >= 0),
    snapshot_hash TEXT,
    accepted_at TEXT,
    state_version INTEGER NOT NULL CHECK (state_version >= 0),
    checkpoint_ref TEXT,
    PRIMARY KEY (verifier_id, registry_id),
    CHECK ((highest_version = 0 AND snapshot_hash IS NULL)
        OR (highest_version > 0 AND snapshot_hash IS NOT NULL))
) STRICT;

CREATE TABLE verifier_checkpoint_receipts (
    receipt_id TEXT PRIMARY KEY,
    verifier_id TEXT NOT NULL,
    registry_id TEXT NOT NULL,
    checkpoint_version INTEGER NOT NULL CHECK (checkpoint_version >= 0),
    snapshot_hash TEXT,
    external_checkpoint_ref TEXT NOT NULL,
    recorded_at TEXT NOT NULL,
    recovery_event_ref TEXT
) STRICT;
```

The high-water mark update must be compare-and-swap/monotonic: accept a new snapshot only if its version is greater than the stored version, or if it is the same version with the identical hash under the explicitly approved idempotency rule. Same version with a different hash is an integrity incident. A lower version is rejected.

The external checkpoint receipt table stores references and audit correlation only. The actual checkpoint must be protected outside this SQLite file and independently of ordinary database backups. Restoring an old SQLite backup must trigger reconciliation against that external checkpoint before trust decisions resume.

## 5. Indexes and uniqueness

Candidate indexes (subject to query-plan tests):

```sql
CREATE INDEX idx_mandates_by_issuer
    ON mandates(issuer_id);

CREATE INDEX idx_issuer_versions_status
    ON issuer_versions(status, issuer_id, record_version);

CREATE INDEX idx_mandate_versions_status
    ON mandate_versions(status, mandate_id, record_version);

CREATE INDEX idx_key_versions_status
    ON issuer_key_versions(status, key_id, record_version);

CREATE INDEX idx_transition_events_target
    ON transition_events(record_type, record_id, resulting_record_version);

CREATE INDEX idx_snapshots_latest
    ON registry_snapshots(registry_id, version DESC);

CREATE INDEX idx_approvals_pending
    ON administrative_approvals(decision, created_at)
    WHERE decision = 'PENDING';
```

Because version history is append-only, each version table's composite primary key prevents duplicate version numbers. A domain service must additionally enforce that a newly inserted version is exactly the expected successor (or another explicitly approved versioning rule), not merely greater than zero.

## 6. Transaction boundaries

Use explicit transactions. The exact SQLite transaction mode and retry policy should be selected and tested for the supported concurrency pattern.

### 6.1 Protected state transition

One logical transition must atomically:
1. load the current record version and state;
2. verify the expected prior version and legal state-machine edge;
3. authenticate the actor through the external identity layer;
4. authorize the actor and validate required independent approval;
5. validate the approval's target, action, digest, and version;
6. insert the new immutable record version;
7. insert the transition event;
8. consume or mark the administrative approval as used, if the approved workflow requires it;
9. commit all effects together.

If any step fails, no partial transition or approval consumption remains. Concurrent attempts against the same prior version must result in at most one successful commit.

### 6.2 Snapshot publication

Snapshot publication must capture a consistent committed registry state. In one transaction:
- select the exact issuer, mandate, and key record versions;
- construct canonical snapshot content according to the approved canonicalization specification;
- calculate the content hash;
- persist the snapshot envelope and its membership rows;
- ensure the version is the next permitted registry version.

Signing should occur through the separately controlled registry signing-key mechanism. If signing is external, define how the signed result is bound back to the exact immutable snapshot payload and how failed/abandoned signing attempts are handled. Do not hold a database write transaction open across an unbounded external signing call without a reviewed design.

### 6.3 Verifier acceptance and high-water update

The verifier must:
- authenticate and validate the snapshot signature against a trusted registry key;
- validate freshness and the exact snapshot content/hash;
- compare version/hash against its local high-water mark;
- reconcile with the independently protected checkpoint;
- atomically persist the monotonic local state and an audit/checkpoint reference;
- return non-ALLOW if any trust input is missing, stale, conflicting, or unverifiable.

A crash between local persistence and external checkpoint acknowledgement must have a defined idempotent recovery protocol. That protocol remains unresolved and must be designed before implementation.

### 6.4 Revocation and approval consumption

The system must define a decision point/linearization contract before implementing concurrent verification and revocation. A request whose decision point occurs after a revocation becomes effective must not return ALLOW based on stale status.

Single-use approval check and consumption must be atomic with the protected operation. A read-then-write sequence outside one transaction is insufficient.

## 7. Enforcement-layer allocation

| Requirement | Primary enforcement layer | SQLite contribution | Additional requirement |
|---|---|---|---|
| Unique immutable IDs | Schema + domain service | PRIMARY KEY / UNIQUE | Never reuse after deletion/retirement |
| Issuer/mandate/key relationships | Schema + domain service | Foreign keys | Cross-record semantic checks |
| Legal state transitions | Domain service | Versioned rows; optional triggers | Authenticated authorization and approval |
| No self-approval | Authorization policy | Limited CHECK constraints | Principal identity and operation-specific rules |
| Exact-change approval | Domain service | Digest/version columns | Canonical request digest and signature/evidence policy |
| Snapshot authenticity | Cryptographic verifier | Stores signature/hash | Separate registry trust anchor |
| Anti-rollback | Verifier + external checkpoint | Local monotonic state | Independent durable checkpoint/recovery |
| Append-only history | Restricted repository layer + operational controls | INSERT-only access pattern/triggers | Independent checkpoint and backup protection |
| Revocation consistency | Transaction/service | Atomic writes | Defined linearization and freshness policy |
| Privacy | Data model + access control | Minimized columns/references | Protected evidence store, retention and access policy |
| Synthetic-only | Test/build controls | No special guarantee | Fixture validation and repository review |

## 8. Decisions still blocking migration implementation

These decisions must be resolved by accountable governance/security owners. This document intentionally does not choose defaults:

1. **Validity:** mandatory start/end fields, whether open-ended periods are allowed, interval boundary convention, UTC representation, and clock tolerance.
2. **Canonicalization:** exact serialization algorithm/version, hash algorithm, null/omitted semantics, and snapshot schema evolution.
3. **Snapshot chain:** whether previous-version linkage is sequence-only or requires the previous content hash (the proposed columns support both).
4. **Registry trust anchor:** initial provisioning, rotation, emergency compromise, revocation, and recovery of the registry signing key.
5. **External high-water checkpoint:** operator, technology, durability, access policy, acknowledgement protocol, backup/restore behavior, and authorized re-bootstrap.
6. **Administrative cardinality:** operation-specific requester/reviewer/approver independence and emergency suspension rules.
7. **Revocation decision point:** consistency guarantee, linearization point, permitted cache freshness, outage behavior, and historical-evidence treatment.
8. **Public-key storage:** inline public bytes versus external reference, key encoding, and fingerprint algorithm.
9. **Scope/audience representation:** canonical vocabulary, schema validation, audience namespace and lifecycle.
10. **Privacy/retention:** classification, access, correction, retention, deletion exceptions, and protected evidence reference lifecycle.

An unresolved decision blocks the affected capability. It is not permission for developers to choose a convenient value.

## 9. Required synthetic schema and transaction tests

Before a migration PR can be considered complete, tests should cover at least:

- foreign keys reject orphan mandates, keys, and snapshot membership rows;
- duplicate IDs and duplicate record versions are rejected;
- issuer/mandate/key IDs are never reused after terminal states;
- illegal state transitions and terminal-state reactivation are rejected;
- active versions cannot omit required validity/approval fields under the finally approved policy;
- mandate scope cannot exceed issuer authority;
- activated public-key material cannot be changed under an existing key ID;
- private-key material is rejected by fixture/build validation and never appears in stored records;
- snapshot membership resolves to the exact immutable versions represented by its content;
- a snapshot with modified content, signature, metadata, or previous-version linkage is rejected;
- lower snapshot versions and same-version/different-hash snapshots are rejected;
- restoration of an old database backup is detected by external checkpoint reconciliation;
- conflicting concurrent transitions cannot both commit;
- concurrent single-use consumption permits no more than the policy-defined number of successful uses;
- revocation races respect the approved decision-point contract;
- transition events cannot be updated/deleted through application data access;
- crash/retry cases around checkpoint acknowledgement are idempotent and fail closed;
- positive control fixture with all required synthetic trust inputs succeeds.

All tests must use fabricated identities, keys, organizations, and approval data. Passing tests demonstrates only the behavior of the synthetic engineering prototype.

## 10. Implementation exit criteria

Do not create migrations or runtime registry code until:
- the blocking decisions in Section 8 are resolved for the intended first implementation slice;
- each schema constraint has a corresponding test;
- every invariant has a named enforcement layer;
- external checkpoint and recovery behavior are specified before anti-rollback is claimed;
- snapshot canonicalization and registry trust bootstrap are specified before snapshot signing/verification is implemented;
- revocation and consumption semantics are specified before concurrent use is implemented;
- the supported SQLite version and connection settings are tested;
- the prototype remains isolated and synthetic-only.

This document adds no runtime behavior. It must not be interpreted as approval for a real issuer registry or deployment.
