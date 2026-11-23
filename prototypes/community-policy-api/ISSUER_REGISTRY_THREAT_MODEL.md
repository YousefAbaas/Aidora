# Issuer Registry Threat Model

**Status:** design-only security analysis; not an implemented control set.  
**Scope:** the isolated, synthetic community-policy API prototype.  
**Related design:** `ISSUER_GOVERNANCE_DESIGN.md`.  
**Last updated:** 2026-11-24.

## 1. Purpose and safety boundary

This threat model identifies ways an issuer registry, mandate records, signing keys, revocation data, and registry snapshots could be abused or fail. It translates those risks into proposed preventive controls, detection and response expectations, and synthetic security tests.

This document does not establish a real community authority, register a real issuer, assign real administrative roles, or authorize access to real participant data. It does not claim that Aidora, its developers, SRHIN, or any other organization has a community mandate. All future examples and tests must use synthetic identities, mandates, keys, approvals, and data.

The current prototype does **not** implement an issuer/mandate registry, administrative authorization, registry snapshots, registry rollback protection, audience binding, or the state machines described in the related design. The controls below are requirements for a separately reviewed future design, not statements about current protection.

## 2. System assets and security objectives

### Assets to protect

- Issuer identity records and the evidence supporting them.
- Mandate records, scopes, effective periods, review decisions, and status.
- Public-key records, key IDs, issuer bindings, validity periods, and status.
- Issuer-side private signing keys and signing operations.
- Approval evidence, including its subject, policy/version, purpose, action, context, audience, validity, and use/revocation status.
- Registry snapshots, signatures, versions, freshness metadata, and verifier high-water marks.
- Administrative identities, role assignments, approval decisions, and transition history.
- Audit records, integrity checkpoints, backups, and recovery material.
- Confidential governance material and any personal or sensitive metadata.

### Security objectives

1. **Authenticity:** registry records and snapshots come from an authorized registry authority.
2. **Authorization:** only appropriately authorized and independently checked actors can propose or approve sensitive changes.
3. **Scope integrity:** issuer, mandate, key, and approval scopes cannot be silently widened.
4. **Lifecycle integrity:** only permitted state transitions can occur; terminal states cannot be reactivated by editing a status field.
5. **Freshness and anti-rollback:** a verifier cannot accept an older registry state after observing a newer one.
6. **Revocation consistency:** suspension or revocation takes effect according to a documented, testable consistency model.
7. **Confidentiality and privacy:** registry and audit data disclose no more than is necessary.
8. **Availability with safe failure:** service outages must not cause an untrusted state to be treated as trusted.
9. **Accountability:** material administrative and verification events are attributable and tamper-evident.
10. **Relying-party binding:** approval evidence is accepted only by its intended audience or an explicitly authorized audience set.

## 3. Trust boundaries and assumptions

The proposed architecture has distinct trust boundaries:

- **Governance decision boundary:** affected people and accountable governance bodies determine whether a mandate exists and what it permits. Software cannot establish legitimacy by itself.
- **Registrar boundary:** a registrar records independently reviewed identity, mandate, and key evidence.
- **Issuer boundary:** a signing component holds private keys and issues evidence only within an approved mandate.
- **Registry boundary:** an authoritative service stores versioned records and publishes authenticated snapshots/status.
- **Verifier boundary:** a relying service checks evidence, issuer/mandate/key state, audience, freshness, and use rules.
- **Audit boundary:** security events are retained and independently checkpointed.
- **Operator boundary:** infrastructure operators administer services but must not acquire unreviewed authority to invent mandates or approve their own changes.

Assumptions requiring explicit validation before implementation:

- The accountable host and affected communities have defined the governance process and its decision authority.
- Registry signing keys and issuer signing keys have separate, documented ownership and custody.
- The system has a trustworthy way to persist a verifier's highest accepted registry version.
- Clock synchronization and maximum status staleness are defined by risk owners.
- The behavior during registry outage, partition, recovery, and conflicting updates is specified.
- The exact semantics of historical evidence after key compromise or mandate revocation are decided by accountable governance owners.

If an assumption is not met, the verifier must not infer trust from missing data or operator convenience.

## 4. Threat severity

- **Critical:** can cause unauthorized approval evidence to be accepted, grant an illegitimate issuer authority, bypass an effective revocation, or cross a relying-party boundary.
- **High:** can materially undermine integrity, accountability, availability, or lifecycle enforcement, but requires additional conditions or does not directly guarantee unauthorized acceptance.
- **Medium:** can expose confidential metadata or degrade operations without directly defeating the core trust decision.

Severity is a design priority, not a measured exploitability score. Reassess it when deployment architecture and threat actors are known.

## 5. Threat register

| ID | Threat / priority | Attacker capability and attack path | Impact | Preventive controls | Detection and response | Synthetic test |
|---|---|---|---|---|---|---|
| T01 | Rogue registrar — **Critical** | An insider or compromised account creates or activates an issuer without valid independent review. | An unauthorized issuer may be treated as trusted. | Strong registrar authentication; least privilege; independent approval; separation between submission and approval; signed/versioned registry events. | Alert on issuer activation and registrar changes; suspend affected record; preserve evidence; independently review all records approved by the compromised actor. | ST01: unauthorized registrar attempts registration/activation; expect rejection and an audit event. |
| T02 | Mandate forgery — **Critical** | Attacker fabricates, substitutes, or alters mandate evidence or its approval reference. | False authority is attributed to an issuer. | Verify mandate evidence through an independently defined process; bind evidence to issuer, scope, validity, decision reference, and version; protect source records. | Detect signature/reference mismatch and duplicate identifiers; quarantine record; initiate independent review. | ST02: altered, missing, or unverifiable mandate evidence is rejected. |
| T03 | Mandate scope escalation — **Critical** | Authorized or compromised actor widens subjects, purposes, actions, contexts, constituency, or audience without approval. | Issuer acts beyond its mandate. | Immutable/versioned scope changes; explicit approval for every scope expansion; verifier enforces exact scope intersection. | Alert on scope changes; compare versions; suspend affected mandate pending review. | ST03: request outside mandate scope and unapproved scope expansion are rejected. |
| T04 | Unauthorized key registration — **Critical** | Attacker adds a public key without proving possession or validating its issuer binding. | Attacker-controlled signatures may be accepted. | Proof-of-possession challenge; independent registrar review; issuer and mandate binding; approved algorithm and validity metadata. | Alert on new or changed key records; revoke/quarantine suspicious key; inspect evidence verified since activation. | ST04: key without valid registration and proof of possession is rejected. |
| T05 | Key substitution — **Critical** | Attacker replaces a public key while retaining an existing `key_id`. | Old and new key identities become ambiguous; forged evidence may pass. | Key records immutable after activation; new key requires a new ID and versioned rotation event; never silently overwrite key material. | Compare key fingerprints and history; alert on attempted replacement; suspend affected key record. | ST05: changing public-key bytes under an existing key ID is rejected. |
| T06 | Private-key compromise — **Critical** | Attacker steals issuer private key or gains control of the signing service. | Attacker can create cryptographically valid but unauthorized evidence. | Isolated signing service; restricted access; managed/hardware-backed custody where appropriate; rotation and emergency suspension procedures; no private keys in verifier or repository. | Detect unusual signing patterns and access; suspend key immediately; investigate compromise window; assess evidence issued during that interval under an approved incident policy. | ST06: compromised/suspended key cannot issue or verify new acceptable evidence; incident-window evidence is flagged for policy review. |
| T07 | Key ID reuse — **High** | Operator reuses an identifier after retirement, revocation, or key rotation. | Historical evidence may resolve to the wrong key. | Globally unique, never-reused key IDs; retain tombstones for retired/revoked identifiers. | Alert on duplicate identifiers and inconsistent fingerprints; quarantine conflicting records. | ST07: registration using a previously used key ID is rejected. |
| T08 | Registry rollback — **Critical** | Attacker replays an older, correctly signed registry snapshot after a key or mandate was suspended/revoked. | Revoked authority may become trusted again. | Monotonic versions; persistent verifier high-water mark; signed snapshots; previous-version linkage; rollback-resistant storage/anchor. | Alert on lower or repeated stale version; reject snapshot; investigate verifier state and restore trusted checkpoint. | ST08: snapshot below highest accepted version is rejected even if its signature is valid. |
| T09 | Stale snapshot — **High** | Verifier continues using a cached snapshot beyond its approved freshness bound. | Recent suspension or revocation is missed. | Explicit snapshot expiry and maximum staleness; authenticated status refresh; fail-closed policy after expiry. | Monitor snapshot age and refresh failures; alert before expiry; stop trust decisions when freshness limit is exceeded. | ST09: expired or over-age snapshot cannot produce ALLOW. |
| T10 | Registry signature replay — **High** | Attacker replays an old signed update or snapshot with valid cryptographic integrity. | Prior state is reintroduced or event ordering is confused. | Bind signatures to registry ID, version, issue/expiry times, and content hash; enforce monotonic sequence and unique event IDs. | Detect duplicate event IDs, version gaps, and replay; reject and retain forensic metadata. | ST10: replayed signed event/snapshot is rejected as duplicate or stale. |
| T11 | Revocation race — **Critical** | Verification/consumption runs concurrently with key, mandate, issuer, or approval revocation. | Evidence may be accepted after its effective revocation. | Define linearization point and consistency model; transactional status check plus consume; version preconditions; explicit effective-time semantics. | Record ordering and versions; alert on any ALLOW whose decision point follows effective revocation; suspend affected verifier if consistency is uncertain. | ST11: deterministic concurrent test proves no ALLOW after the defined revocation linearization point. |
| T12 | Split-brain registry — **High** | Network partition or conflicting writes cause replicas to publish different current states. | Different verifiers make contradictory trust decisions. | Single authoritative write path or consensus-backed versioning; conflict detection; signed snapshots from one authority; no local independent status edits. | Compare version/hash across replicas; alert on divergence; stop trust decisions on inconsistent state. | ST12: two conflicting registry heads cause fail-closed behavior. |
| T13 | Self-approval — **Critical** | Same actor submits and approves issuer, mandate, or high-impact key activation. | One compromised or self-interested actor can create trusted authority. | Enforce incompatible-duty rules in authorization logic; require independent approver(s) for sensitive changes. | Audit actor/approver identity; alert on same-principal or linked-account approval; suspend and review. | ST13: same principal cannot both submit and approve a protected change. |
| T14 | Role collusion — **High** | Multiple authorized actors coordinate to approve an improper change. | Formal separation of duties is bypassed in practice. | Independent oversight; diverse approval paths where appropriate; transparent decision references; periodic access review. | Review unusual approval patterns and conflicts; independent investigation and credential suspension where warranted. | ST14: test policy rejects insufficiently independent or conflicting approval identities; note that software cannot fully detect human collusion. |
| T15 | Unauthorized state transition — **High** | Actor bypasses transition rules through direct status update or stale concurrent write. | Revoked/expired/suspended record is improperly reactivated or state history lost. | Central transition validator; append-only events; optimistic concurrency/version checks; terminal-state rules. | Alert on invalid transition attempts and state/version mismatch; preserve attempted event. | ST15: invalid transitions and stale updates are rejected; terminal states cannot be reactivated in place. |
| T16 | Audit tampering or truncation — **High** | Attacker modifies events or deletes a valid log suffix/checkpoint. | Misconduct or unauthorized changes become difficult to detect. | Append-only storage; independent signed checkpoints; external anchoring or separately controlled copies; protected retention and backups. | Periodic integrity verification; compare independent checkpoints; incident response and restore from trusted copy. | ST16: modification, deletion, reordering, and suffix truncation are detected against an independent checkpoint. |
| T17 | Sensitive registry disclosure — **Medium** | Unauthorized user accesses identity documents, membership details, deliberations, or sensitive metadata. | Privacy harm, exposure of vulnerable people, or retaliation. | Data minimization; separate evidence vault; field-level access controls; encryption; retention limits; privacy review. | Monitor unusual reads/exports; access review; contain exposure and follow approved notification process. | ST17: unauthorized role cannot retrieve protected fields; public snapshot contains only approved minimum data. |
| T18 | Registry denial of service — **High** | Attacker overloads or disables registry/status infrastructure or blocks refresh. | Verifiers cannot establish current trust status. | Rate limits; resilient hosting; backups; recovery drills; bounded caching; no fail-open fallback. | Availability and freshness monitoring; incident escalation; fail closed when trusted status expires. | ST18: unavailable registry and expired cache never result in ALLOW. |
| T19 | Approval replay — **High** | Attacker reuses evidence beyond its permitted one-time or bounded-use semantics. | Duplicate or unauthorized action occurs. | Signed scope and audience; unique approval ID; atomic consumption; explicit repeat-use policy. | Detect duplicate use and concurrency anomalies; revoke or quarantine affected approval according to policy. | ST19: parallel duplicate consumption yields no more successful uses than policy permits. |
| T20 | Audience confusion — **Critical** | Evidence issued for one host, service, tenant, or deployment is presented to another. | Approval is accepted by an unintended relying party. | Include stable audience in signed claims when recipient-specific; verifier compares against configured audience; document any approved audience set. | Log audience mismatch reason code; investigate unexpected cross-service presentation. | ST20: missing, mismatched, or unauthorized audience is rejected whenever audience binding is required. |

## 6. Cross-cutting design requirements

### 6.1 Fail-closed trust decisions

The verifier must not return `ALLOW` if any required trust input is missing, malformed, stale, inconsistent, unverifiable, revoked, suspended, expired, compromised, or outside scope. A non-ALLOW result such as `REVIEW` may be appropriate for operational handling, but must not be treated downstream as permission.

### 6.2 Versioned, append-only changes

Issuer, mandate, key, registry, and administrative-role changes should be represented as versioned events. A state transition must include the target record/version, prior and new state, effective and recorded times, reason category, decision reference, and authenticated actor/approver identities. A role label supplied in a request is not proof of authorization.

### 6.3 Revocation consistency contract

Before implementation, specify:

- what event makes revocation effective;
- whether checks are linearizable, strongly consistent, or bounded-stale;
- the maximum permitted status staleness and who approves it;
- how verification and one-time consumption are made atomic;
- what happens during partitions and registry outages;
- how historical evidence is assessed after issuer/mandate changes or key compromise.

Do not select a freshness duration or historical-evidence rule solely for implementation convenience.

### 6.4 Registry snapshot contract

A signed snapshot should bind at least registry ID, monotonic version, issue time, expiry time, previous-version reference, and content integrity. Verifiers must persist a trustworthy high-water mark. A signature without anti-rollback state is insufficient.

### 6.5 Administrative authorization

Sensitive operations should use authenticated principals, least-privilege roles, incompatible-duty checks, explicit approval evidence, and optimistic concurrency. Submission, review, approval, activation, suspension, and revocation must be separately attributable. Emergency suspension may be faster than ordinary approval but must trigger retrospective review under a documented process.

### 6.6 Privacy and audit

Keep sensitive source evidence separate from public verification metadata. Audit reason codes and references rather than copying sensitive narratives. Protect audit history with independent checkpoints; an unanchored hash chain cannot prove that its final suffix was not deleted.

## 7. Prioritized synthetic security test suite

The test IDs below map to the threat register. Tests should use fabricated issuers, mandates, keys, approvals, clocks, registry snapshots, and actors only.

| Test ID | Threat IDs | Setup / action | Expected result |
|---|---|---|---|
| ST01 | T01 | Unprivileged or unauthorized registrar submits/activates issuer. | Reject; no trusted record created; security event recorded. |
| ST02 | T02 | Alter mandate evidence, issuer binding, signature, or decision reference. | Reject; no active mandate. |
| ST03 | T03 | Request an action/purpose/audience outside mandate scope; attempt unapproved scope expansion. | Reject; existing approved scope remains unchanged. |
| ST04 | T04 | Register key without proof of possession or required approval. | Reject; key remains untrusted. |
| ST05 | T05 | Change public-key bytes while retaining an existing key ID. | Reject; preserve prior record and record attempted substitution. |
| ST06 | T06 | Mark a key compromised/suspended and attempt signing/verification; test evidence from incident interval. | New use rejected; historical evidence routed through explicit incident policy, never assumed valid solely from signature. |
| ST07 | T07 | Re-register a retired or revoked key ID with different key material. | Reject permanently reused identifier. |
| ST08 | T08 | Present an older but correctly signed snapshot after a newer version was accepted. | Reject rollback using persisted high-water mark. |
| ST09 | T09 | Present expired or over-age snapshot while registry refresh is unavailable. | No ALLOW. |
| ST10 | T10 | Replay a previously accepted signed snapshot or registry event. | Reject duplicate/stale event. |
| ST11 | T11 | Race verification/consumption against effective revocation using controlled concurrency. | No ALLOW whose decision point is after revocation's defined linearization point. |
| ST12 | T12 | Supply two different registry heads for the same registry/version. | Detect inconsistency and fail closed. |
| ST13 | T13 | Same authenticated principal submits and approves protected change. | Reject due to incompatible duties. |
| ST14 | T14 | Attempt approval with conflicting or insufficiently independent principals. | Reject under configured independence policy; document residual human-collusion risk. |
| ST15 | T15 | Attempt illegal transition, direct status overwrite, terminal-state reactivation, and stale-version update. | Reject; prior state/history remains intact. |
| ST16 | T16 | Alter, reorder, delete, and truncate audit events after checkpoint. | Integrity verification detects each alteration. |
| ST17 | T17 | Query protected registry fields using an unauthorized role. | Deny; no sensitive content disclosed. |
| ST18 | T18 | Disable registry/status service and expire local snapshot. | No ALLOW; operational alert emitted. |
| ST19 | T19 | Submit same one-time approval concurrently from multiple workers. | At most the policy-permitted number of consumptions succeeds. |
| ST20 | T20 | Present missing, mismatched, or unauthorized audience. | Reject whenever audience binding is required by the evidence profile. |

Tests must also cover valid control cases: a properly reviewed synthetic issuer, in-scope active mandate, correctly registered active key, current registry snapshot, matching audience, and valid unused approval should pass. Negative-only suites can otherwise conceal an implementation that rejects everything.

## 8. Acceptance criteria

A future synthetic Registry prototype is not ready for security review until:

- [ ] Every threat T01–T20 has an explicit control owner and implementation status.
- [ ] Issuer, mandate, and key records use the separately reviewed state machines.
- [ ] Sensitive state changes are authenticated, authorized, versioned, and auditable.
- [ ] Incompatible duties and self-approval are enforced server-side.
- [ ] Key IDs are never reused and activated key material cannot be silently substituted.
- [ ] Registry snapshots are authenticated, time-bounded, monotonic, and rollback-protected.
- [ ] Verifier freshness and outage behavior are explicit and fail closed.
- [ ] Revocation and consumption have a documented atomicity/consistency contract.
- [ ] Audience binding is implemented and tested for the evidence profiles that require it.
- [ ] Audit integrity is checked against independent checkpoints, including truncation.
- [ ] Privacy controls prevent unnecessary exposure of identity and governance evidence.
- [ ] All ST01–ST20 tests and valid positive control cases pass in isolated synthetic fixtures.
- [ ] Independent security review has assessed residual risks and documented unresolved findings.

Passing these tests does not establish community legitimacy, informed consent, legal compliance, or authorization for a real-world pilot. Those require separate accountable governance, safeguarding, privacy, and host approval.

## 9. Known current gaps

At the time of writing, the existing prototype has no issuer/mandate Registry or administrative authorization layer. The current operator-configured Ed25519 keyring binds key IDs to issuer IDs but does not independently validate mandates or issuer status. The approval store is local SQLite; its revocation method is a storage primitive without caller authorization. The audit chain is in-memory and lacks independent durable anchoring. Approval evidence is not audience-bound. These are known limitations and must not be represented as mitigated by this document.

## 10. Recommended implementation order

1. Review and agree the governance decisions and trust boundaries before encoding authority.
2. Build isolated synthetic record schemas and transition validators.
3. Add authenticated administrative authorization and separation-of-duties checks.
4. Add signed, versioned registry snapshots and rollback protection.
5. Add verifier checks for issuer, mandate, key, scope, freshness, and audience.
6. Define and test revocation/consumption consistency.
7. Add independently checkpointed audit events and privacy controls.
8. Run ST01–ST20 plus positive controls, recovery tests, and independent review.

Do not connect the synthetic model to real people, real community authorities, production Aidora, SRHIN, or sensitive datasets without a separate, explicit governance and safety decision.
