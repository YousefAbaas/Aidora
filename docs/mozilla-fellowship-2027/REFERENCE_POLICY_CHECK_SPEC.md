# Reference policy-check specification — synthetic only

**Status:** A candidate engineering specification for discussion and testing. It is not a confirmed SRHIN requirement, an SRHIN policy, a community-approved data model, or a production access-control design.

## 1. Problem boundary

The only problem this component could address is a narrowly defined downstream hand-off: a system receives a request to perform an action on a dataset and needs to check a current, already-authorised policy record before allowing that action.

It does not decide who legitimately represents a community, whether a consent process was valid, whether a study is ethical, whether a contract is enforceable, or whether an AI model may lawfully be trained. Those determinations remain with the relevant people, institutions, legal agreements, and oversight processes.

## 2. Input contract (illustrative, not host-specific)

### Policy record

| Field | Type | Meaning |
|---|---|---|
| policy_id | opaque string | Reference to a policy record; must not contain a participant identity |
| version | string | Immutable policy version |
| status | active / draft / revoked | Current state from an authoritative source |
| effective_from | timezone-aware timestamp | Start of validity |
| expires_at | optional timezone-aware timestamp | End of validity |
| allowed_purposes | string list | Purposes explicitly permitted |
| denied_purposes | string list | Explicitly prohibited purposes |
| allowed_actions | string list | Actions explicitly permitted |
| denied_actions | string list | Explicitly prohibited actions |
| required_approvals | string list | Approval categories required by the authoritative workflow |
| required_context | key/value map | Technical conditions, e.g. approved environment |
| review_required | boolean | Explicit escalation flag |

### Access request

| Field | Type | Meaning |
|---|---|---|
| purpose | string | Requested purpose |
| action | string | Requested action |
| approvals | list | Verifiable approval evidence references from an authoritative system |
| context | key/value map | Minimal technical context needed for this check |

The reference prototype uses synthetic string references for approvals. In a real system, these must be replaced with verifiable, authenticated evidence and a host-approved trust model. The prototype's strings prove nothing.

## 3. Decision precedence

Evaluate in this order. A higher-priority outcome cannot be overridden by a lower-priority condition.

1. **Malformed or incomplete input → REVIEW.** Missing policy fields, invalid timestamps, missing purpose/action, absent approval evidence, or unknown required context must never result in ALLOW.
2. **Explicit revocation → DENY.** A revoked policy cannot authorise a new request.
3. **Policy not active or not yet effective → REVIEW.** A draft, suspended, or future policy needs authoritative clarification.
4. **Expired policy → DENY.** An expired policy cannot authorise a new request.
5. **Explicit purpose/action prohibition → DENY.**
6. **Purpose/action not explicitly allowed → DENY.** No implicit wildcard or default permission.
7. **Required approval rejected → DENY.**
8. **Required approval absent, incomplete, or contradictory → REVIEW.**
9. **Required technical context absent → REVIEW; context contradicts a hard condition → DENY.**
10. **Human/community review explicitly required → REVIEW.**
11. **Only if every required condition is explicitly satisfied → ALLOW.**

The order and semantics are deliberately conservative. SRHIN and affected communities would need to approve the real precedence rules, including how conflicts between individual choice, collective governance, agreements, and law are resolved. Software must not silently resolve such conflicts.

## 4. Output contract

Every response contains:

- `decision`: exactly one of `ALLOW`, `DENY`, or `REVIEW`;
- `policy_id` and `policy_version`: the policy record evaluated;
- `reason_codes`: stable machine-readable reasons, without sensitive content.

Do not include participant identifiers, health data, free-text consent, clinical details, or sensitive community deliberations in the response or logs.

## 5. Minimum security requirements before any real use

- Authenticate the caller and verify its authority to request a check.
- Retrieve policy and approval evidence from authoritative, integrity-protected sources.
- Verify signatures or equivalent tamper-evident provenance; do not trust caller-supplied approval strings.
- Enforce the decision at the actual data-access boundary; eliminate bypass routes.
- Protect against replay, stale cache, time-of-check/time-of-use races, policy rollback, and version confusion.
- Log only the minimum metadata needed for audit, with restricted access and retention limits.
- Rate-limit and monitor the endpoint; define incident response and key rotation.
- Ensure policy updates and revocations propagate within an agreed, tested time.
- Provide a human/community challenge and correction path.
- Conduct independent security and privacy review before real data is in scope.

If the system cannot enforce the check at the relevant boundary, it must not present itself as an access-control safeguard.

## 6. Synthetic acceptance cases

| Case | Expected result | Reason |
|---|---|---|
| Active policy, explicit purpose/action, all required approvals, context matches | ALLOW | All explicit conditions satisfied |
| Purpose explicitly prohibited | DENY | Explicit prohibition |
| Purpose absent from allow-list | DENY | No implicit permission |
| Action absent from allow-list | DENY | No implicit permission |
| Required approval missing | REVIEW | Evidence incomplete |
| Required approval rejected | DENY | Explicit rejection |
| Conflicting approval records | REVIEW | Authoritative reconciliation needed |
| Policy revoked | DENY | Revocation |
| Policy expired | DENY | Expiry |
| Policy is draft or not yet effective | REVIEW | Not currently authoritative |
| Required context missing | REVIEW | Cannot verify condition |
| Required context contradicts hard constraint | DENY | Condition not met |
| Human/community review required | REVIEW | Escalation required |
| Invalid or timezone-naive timestamp | REVIEW | Validity cannot be established |

The companion prototype implements a subset of these cases with synthetic data and standard-library unit tests. It is a teaching/reference artifact, not a certified policy engine.

## 7. Standards mapping: keep the boundaries clear

- **GA4GH DUO** is a vocabulary for tagging datasets with permitted-use terms. It is not, by itself, a complete community-governance decision process or an enforcement engine.
- **GA4GH Passports** encode a researcher's identity-related information and access authorisations in Passport Visas. They are not a generic participant-consent record.
- **GA4GH Data Passports** are an active-engagement technical specification effort extending Passports with dataset-level policy attributes. Treat this as evolving work; do not assume a stable, approved implementation profile.
- **GA4GH Machine-Readable Consent Guidance** maps consent language to DUO terms; mapping does not establish that consent is valid, sufficiently informed, or a substitute for collective governance.
- **W3C ODRL 2.2** provides a general information model for permissions, prohibitions, constraints, and duties. Its flexibility does not automatically supply community-specific semantics or enforcement.

The correct result may be that none of these standards fits a particular community-defined condition. Record that gap honestly rather than forcing a mapping.

## 8. Build gate

Do not adapt this reference code into a host integration unless all of the following are true:

1. SRHIN identifies a concrete workflow and confirms that the gap is material.
2. Affected communities define and approve the relevant decision rights and challenge route.
3. Existing SRHIN systems and processes do not already solve the problem adequately.
4. The authoritative source of policy and approval evidence is identified.
5. The host approves the data boundary, integration point, security model, and maintainer.
6. Legal, ethics, privacy, safeguarding, and security approvals are complete for the proposed scope.

If any condition is not met, keep the prototype synthetic-only, adapt an existing system, or choose no-build.
