# Issuer Governance Design

**Status:** design proposal for review; not an implemented trust or governance system.  
**Scope:** the isolated synthetic community-policy API prototype in this directory.  
**Last updated:** 2026-11-24

## 1. Purpose

The prototype can verify that an approval-evidence token was signed by the private key corresponding to a configured Ed25519 public key. Cryptographic verification does **not** establish that the key holder is a legitimate representative of a community, that the issuer was authorized for a particular decision, or that the affected people freely agreed.

This document defines the governance questions and minimum controls that must be resolved before any issuer key is treated as representing a real organization or community. It does not assert that Aidora, its developers, a host organization, or any named person has authority to issue or revoke community approvals.

## 2. Non-goals and safety boundary

This proposal does not:

- create a real community authority, council, representative body, or consent process;
- nominate or register any real issuer, key, administrator, or revocation authority;
- treat a signed token, an API `ALLOW`, or a database record as proof of legal, ethical, contractual, or community consent;
- authorize access to real participant, refugee, health, or other sensitive data;
- define a public HTTP endpoint for issuing, registering, rotating, or revoking keys;
- replace host, institutional, legal, ethics, safeguarding, or community-led review;
- claim that a cryptographic signature proves the signer's identity, mandate, informed consent, or absence of coercion.

Until governance is agreed and validated by the relevant affected people and accountable host, the implementation remains synthetic-only.

## 3. Trust model and terminology

Keep these concepts separate:

1. **Identity:** which person or organization controls an issuer credential?
2. **Mandate:** who authorized that person or organization to act, for which constituency and subject matter, and for what period?
3. **Decision process:** how was a specific decision requested, explained, discussed, recorded, and challenged?
4. **Evidence integrity:** has the resulting record been altered, expired, revoked, or replayed?
5. **Relying-party authorization:** is this application permitted to act on this evidence for this exact policy, purpose, action, subject, and context?

Ed25519 addresses evidence integrity and key possession. It does not independently solve identity, mandate, decision quality, or relying-party authorization.

### Roles (logical separation, not assigned people)

- **Community/affected-person governance body:** defines its own representation, participation, decision, appeal, and withdrawal processes.
- **Issuer:** creates a signed record only within a documented mandate.
- **Issuer key custodian:** protects signing credentials; should not unilaterally define the mandate.
- **Governance registrar:** verifies and records the issuer's mandate and approved public-key binding.
- **Revocation authority:** can suspend or revoke an issuer credential or an individual approval under a documented process.
- **Verifier/operator:** configures trusted public keys and verifies evidence; must not silently invent issuer authority.
- **Independent reviewer / oversight contact:** can review disputes, complaints, conflicts of interest, and procedural integrity.

One person or organization may hold more than one role only if the governance process explicitly permits it, documents the conflict, and provides independent checks. High-impact actions should require separation of duties.

## 4. Minimum issuer registration record

Before a public key is trusted for real use, a governance registry would need a verified, versioned record containing at least:

- stable issuer identifier and display name;
- legal or organizational identity evidence, where applicable and safe to collect;
- the constituency or group the issuer claims to represent, described without implying universal representation;
- the documented source, scope, and limits of the issuer's mandate;
- who approved the mandate, how affected people participated, the decision date, review date, and expiry;
- subject areas, policy identifiers, purposes, actions, and contexts for which the issuer may issue evidence;
- approved key IDs, public keys, algorithms, activation times, expiry times, and status;
- identity of the registrar and evidence/reason for the registration decision;
- conflict-of-interest declarations and a dispute/appeal route;
- a public or appropriately access-controlled status record, with privacy-preserving disclosure.

Do not publish personal identity documents, sensitive membership lists, meeting notes, or other identifying data merely to make a registry appear transparent. Publish the minimum information needed to verify status and accountability.

A key must not become trusted merely because an operator adds it to an environment variable. Configuration should be generated from an independently reviewed registry record, with a documented approval trail.

## 5. Approval evidence lifecycle

A real approval process (if one is later designed and approved) should be explicit and auditable:

1. **Define the request:** identify the data or activity, purpose, action, context, duration, risks, and accountable recipient.
2. **Explain and consult:** provide accessible information, allow questions, document dissent and uncertainty, and avoid coercion or retaliation.
3. **Check mandate and quorum:** follow the issuer body's own validated rules; do not invent a universal quorum or majority rule in software.
4. **Record the decision:** record only the minimum necessary evidence, including scope, decision status, decision time, expiry/review date, and a unique approval ID.
5. **Issue evidence:** a separately controlled issuer signs the exact claims. The API verifier receives public keys only.
6. **Verify at use time:** bind evidence to subject, policy ID/version, purpose, action, context, validity period, and issuer/key status.
7. **Consume or record use:** enforce one-time-use or explicitly defined repeat-use semantics transactionally; do not assume all consent is one-time.
8. **Review and withdraw:** provide a documented way to request clarification, correction, suspension, withdrawal, or appeal.

The current prototype binds evidence to a subject, policy/version, purpose, action, context, status, issue time, expiry, issuer ID, and approval ID. This is a technical envelope, not a complete consent record. The current fixed policy and one-time-use store are synthetic design choices and may not fit a future real process.

### Audience / relying-party binding

A future approval-evidence format should define whether evidence is valid for one named relying party (for example, a specific host, service, tenant, or deployment) or may intentionally be reused across a documented set of relying parties. Where approval is intended for a specific recipient, include a stable `audience` identifier in the signed claims and require the verifier to compare it with its own configured audience. Do not rely on an unsigned request field for this check. Define the identifier's namespace, ownership, lifecycle, and migration rules before deployment. If cross-service reuse is permitted, document the exact permitted audience set and the governance basis for that reuse.

The current prototype does **not** bind approval evidence to an audience. This is a known limitation, not an implicit permission for cross-service use. Add audience binding only as a separately reviewed schema and verifier change, with negative tests for missing, mismatched, and unauthorized audiences; do not silently reinterpret existing tokens.

## 6. Key lifecycle

### Generation and custody

- Generate Ed25519 keys using a vetted cryptographic library or managed signing service.
- Generate keys in a controlled environment; never commit private keys, place them in the verifier process, or distribute them through ordinary chat/email.
- Restrict private-key access to the smallest authorized issuer operation.
- Define backup, recovery, compromise response, access logging, and destruction before activation.
- Prefer hardware-backed or managed key custody where feasible and independently reviewed.

### Registration and activation

- Verify the issuer mandate independently of possession of the key.
- Verify proof of possession through a controlled registration challenge.
- Record key ID, public key, issuer binding, allowed scope, activation time, expiry, and approving registrar.
- Require a second authorized reviewer for activation or changes to high-impact issuer credentials.
- A key with no current, verified mandate must not be accepted as a trusted issuer key.

### Rotation

- Publish and approve the replacement public key before the issuer starts using the corresponding private key.
- Define a bounded overlap period and the treatment of evidence issued by the old key.
- Stop signing with the old key at a recorded cutover time.
- Remove the old verification key after the permitted evidence lifetime and any explicitly approved transition period.
- Record who approved the rotation and why. Do not silently replace a key under an existing key ID.

### Suspension and compromise

- Provide an emergency suspension path that can disable a key quickly while a full review is pending.
- Treat suspected private-key compromise as a security incident; suspend first, investigate, then decide whether to revoke or replace.
- Define the effect on tokens issued before the compromise was discovered. A signature alone cannot distinguish legitimate from attacker-created tokens during a compromised-key interval.
- Notify affected parties through an agreed channel when safe and appropriate.

### Expiry and retirement

- Keys and mandates must have explicit expiry/review dates.
- Expiry must fail closed.
- Retired keys should not be reactivated without a new documented approval and review.

## 7. Revocation model

Distinguish at least three operations:

1. **Approval revocation:** invalidates one approval ID.
2. **Key suspension/revocation:** prevents further acceptance of evidence signed by a particular key, subject to a documented policy for historical evidence.
3. **Issuer mandate suspension/revocation:** removes or limits the issuer's authority, potentially across multiple keys.

These are not interchangeable. Revoking an individual approval should not automatically imply that every approval from that issuer is invalid; revoking an issuer mandate may require a broader review of outstanding evidence.

Every revocation record should include a stable target ID, effective time, recorded time, reason category, authorized actor/role, decision or case reference, and review/appeal status. Avoid putting sensitive narratives or personal data in a broadly readable revocation log.

The current SQLite table records `approval_id`, `revoked_at`, `revoked_by`, and `reason`. It does not authenticate or authorize the caller of `revoke()`, validate the actor's mandate, provide an endpoint, or implement issuer/key-level status. It is therefore a storage primitive only—not a revocation governance system.

No public revocation endpoint should be added until actor authentication, authorization, approval workflow, audit requirements, abuse handling, and recovery have been specified and reviewed.

## 8. Registry and verifier architecture

A future design may separate these components:

- **Governance registry:** authoritative, versioned records of issuer mandates, keys, scopes, status, and decisions. Its authority and update process must be independently established.
- **Issuer signing service:** holds private keys and issues narrowly scoped evidence only after its approved decision workflow.
- **Verifier service:** receives public keys and signed evidence; validates signature, claims, time, mandate/key status, and exact request scope.
- **Revocation/status service:** publishes authenticated, freshness-bounded status for approval IDs, keys, and issuer mandates.
- **Audit facility:** records security-relevant events with access control, retention, independent checkpoints, and privacy safeguards.

The verifier must fail closed if the registry/status data is missing, invalid, stale beyond an explicitly approved bound, inconsistent, or unverifiable. A cached registry snapshot needs a signed version, issue time, expiry, and rollback protection. The acceptable maximum staleness must be set by the governance and risk owners—not guessed by the implementation.

The current environment-variable keyring is a local prototype configuration mechanism, not a governance registry. The local SQLite store is not a distributed coordination service. Do not imply otherwise.

## 9. Audit, transparency, and privacy

A future audit trail should record, at minimum:

- registry and mandate version used for verification;
- issuer ID and key ID (not private key material);
- approval ID or a privacy-preserving reference;
- policy ID/version and decision reason codes;
- verification, use, suspension, rotation, and revocation timestamps;
- actor/service identity and authorization decision for administrative actions;
- integrity checkpoints and security-relevant failures.

Apply data minimization, access controls, retention limits, and a documented process for access/correction requests. Avoid logging raw request context, participant identities, sensitive narratives, or full approval tokens unless a reviewed necessity and protection plan exists.

A hash chain alone is insufficient to prove completeness: deletion of a valid final suffix can leave a valid shorter chain. Any production audit design needs independently protected checkpoints or external anchoring, plus backup and recovery procedures.

Transparency should make the rules, authority, status, and avenues for challenge understandable without exposing vulnerable people or confidential deliberations.

## 10. Threats and required mitigations

| Threat | Minimum design response |
|---|---|
| Operator adds an unauthorized public key | Independent mandate verification, registrar separation, signed/versioned registry changes |
| Private key is stolen | Restricted custody, rapid suspension, incident process, defined treatment of affected tokens |
| Issuer mandate expires or is withdrawn | Time-bounded mandate status and fail-closed verifier checks |
| Approval token is copied or replayed | Scope binding and transactional use semantics appropriate to the decision |
| Revocation races with verification/use | Atomic status/consume operation or a clearly defined consistency model |
| Registry/status feed is stale or rolled back | Signed versions, freshness limits, monotonic version checks, fail-closed behavior |
| Issuer exceeds its mandate | Machine-enforced scope plus periodic human review of mandate and decisions |
| Coercion, exclusion, or disputed representation | Community-defined process, accessible consultation, appeal and independent review; cryptography cannot fix this |
| Sensitive information leaks through logs/registry | Data minimization, role-based access, retention and privacy review |
| Local SQLite file is lost or multiple hosts disagree | Backups/recovery and a suitable transactional distributed store before multi-host use |
| Audit tail is deleted or altered | Independent checkpoints/anchoring and protected retention |

## 11. Decisions required before implementation

These questions must be answered by the accountable host and affected communities; the engineering team must not decide them unilaterally:

1. Who are the affected people and which groups may be underrepresented?
2. What body, if any, has a legitimate mandate for each specific decision?
3. How is that mandate established, renewed, limited, challenged, and withdrawn?
4. What participation, accessibility, language, quorum, dissent, and appeal rules apply?
5. Which decisions require individual consent, collective authorization, institutional approval, or more than one of these?
6. Who may issue evidence, and who independently registers or suspends issuer keys?
7. Who may revoke an individual approval, an issuer key, or an issuer mandate?
8. What should happen to already-issued evidence after a mandate change, key compromise, or revocation?
9. What status freshness and availability guarantees are required?
10. What data may be recorded, who can access it, how long is it retained, and how can people challenge or correct it?
11. What legal, ethics, safeguarding, host, and community review is required before any real-world pilot?
12. What existing governance, consent, or accountability mechanisms should be reused rather than duplicated?

Unanswered questions are blockers for real-world use, not implementation TODOs to be filled with developer assumptions.

## 12. Staged implementation plan

### Stage A — design and review (current)

- Keep this document as a proposal.
- Review it with the accountable host and affected communities if a real deployment is ever contemplated.
- Record disagreements, unresolved risks, and decisions without claiming consensus.
- Keep all examples and tests synthetic.

### Stage B — synthetic governance model

Only after the design is reviewed, add a synthetic, non-production schema for issuer mandate, key status, and registry version. Use clearly fake issuers and keys. Test invalid, expired, suspended, out-of-scope, and rolled-back registry states. Do not connect it to real people or services.

### Stage C — administrative authorization prototype

Only after roles and procedures are explicitly approved, prototype authenticated administrative actions with separation of duties, authorization checks, immutable or independently anchored audit events, and negative tests. Do not expose public endpoints by default.

### Stage D — independent security and governance review

Conduct threat modeling, cryptographic review, privacy review, operational recovery tests, and a governance/ethics review with affected people. Resolve findings before considering any pilot.

### Stage E — separately approved pilot decision

A pilot requires explicit written approval from the accountable host and relevant governance bodies, a data protection and safeguarding plan, incident response, support and appeal routes, and a documented rollback plan. An engineering PR or passing test suite is not pilot authorization.

## 13. Current implementation facts

As of this document:

- `approval_evidence.py` verifies Ed25519 signatures using an operator-configured public-key keyring.
- The keyring binds a key ID to an issuer ID, but the issuer ID is an operator assertion, not independently verified mandate.
- The signing helper is issuer-side code in the same prototype package; no real issuer service or HTTP issuance endpoint exists.
- `approval_store.py` persists approval replay and revocation markers in a local SQLite database.
- The `revoke()` method has no built-in caller authentication or role authorization.
- `api.py` uses a fixed synthetic policy and does not consult a mandate registry or issuer status service.
- The audit log is an in-memory synthetic hash chain without durable independent anchoring.
- The adapter is not mounted in the production Aidora backend and is not connected to SRHIN or an external service.

These facts are limitations, not claims of production readiness.

## 14. Acceptance criteria for moving beyond this design

Do not mark issuer governance as implemented until all of the following are true:

- The relevant affected communities and accountable host have reviewed and approved the governance process for the defined scope.
- Issuer identity and mandate verification are documented and independently reviewable.
- Issuer, registrar, verifier, and revocation responsibilities and conflicts are explicitly addressed.
- Key registration, custody, rotation, suspension, compromise, expiry, and retirement are tested.
- Approval, key, and mandate revocation semantics are distinct, authorized, audited, and race-safe.
- Registry freshness, rollback prevention, backup, recovery, and multi-instance consistency are defined and tested.
- Privacy, retention, access, correction, appeal, and incident processes are approved.
- Independent technical, security, privacy, safeguarding, and governance reviews have closed blocking findings.
- A separate, explicit decision authorizes any real-world pilot.

Until then, the only supported use remains synthetic local experimentation.
