# Provisional technical and ethical design

**This is a hypothesis-driven design note, not a production specification.** It must be revised with SRHIN's technical team, clinical/ethics leads, and the communities involved.

## 1. Design principle

Build a small governance service that sits beside an existing, host-approved data workflow. It should govern permissions and evidence of compliant use, not become a second repository of sensitive mental-health records.

The project should not introduce a blockchain, public ledger, central clinical database, or AI screening model unless community and host discovery demonstrates a compelling need. Simplicity, reversibility, and local maintainability take priority.

## 2. Candidate architecture

Participant / trusted facilitator  
→ Accessible consent and preference interface  
→ Consent and governance API  
→ Policy and permission store  
→ Data-use review workflow  
→ Host-approved data platform adapter (only if approved)  
→ Audit and benefit-commitment records

Possible technology choices, subject to host preferences:
- Backend: Python and Django REST Framework, building on the applicant's proven experience.
- Database: PostgreSQL.
- Participant interface: accessible web/mobile interface; Flutter is an option, not a predetermined requirement.
- Integration: versioned REST API and a narrow adapter to GENCurate or another host-selected workflow.
- Deployment: host-approved environment with secrets management, backups, monitoring, and documented maintenance.

Do not assume the host uses the same stack or will permit direct integration. A clean, documented API and export/import path may be more appropriate than deep coupling.

## 3. Minimum data model (candidate only)

The governance store should hold the least information required to enforce and demonstrate the agreed rules.

| Record | Candidate fields | Important boundary |
|---|---|---|
| Participant reference | Random identifier, approved identity-mapping reference | Avoid storing names or clinical narratives in the governance service. |
| Consent version | Version, language, explanation version, timestamp, method | Retain enough evidence to understand what was agreed. |
| Permission | Purpose, data category, recipient class, duration, status | Avoid a single blanket “yes to everything”. |
| Data-use request | Requester role, purpose, dataset/version reference, justification | Must be reviewed according to community-approved rules. |
| Governance decision | Decision, conditions, reviewer role, date, appeal route | Do not silently override participant or community terms. |
| Access event | Actor, action, dataset reference, timestamp, outcome | Restrict access to logs and protect them from tampering. |
| Withdrawal event | Scope, date, requested action, completion status, limitations | Be precise about future use and technical limits. |
| Benefit commitment | Agreed benefit, responsible party, due date, evidence/status | Community determines acceptable benefit; no assumed token/payment scheme. |

The host and community must decide whether these records are personal data, how long they should be retained, where identifiers are stored, and who can see each field.

## 4. Core workflows to test

### A. Initial participation and consent
1. Explain the data use in language and formats selected with participants.
2. Separate service-care permissions from optional research, AI development, and secondary-use permissions.
3. Record the exact notice/version, purpose, scope, and method of agreement.
4. Provide a copy or accessible way to review the current choices.
5. Make clear that refusing optional data use does not affect access to care or services.

### B. New or secondary data use
1. A researcher or system owner submits a purpose-specific request.
2. The service checks existing participant permissions and community rules.
3. If the use is outside the approved scope, it is blocked pending the required review and fresh permission.
4. An authorised community governance process records the decision and any conditions.
5. The system records approved access and downstream-use declarations.

### C. Change or withdrawal
1. A participant can request a change or withdrawal through an accessible channel.
2. The system records the request and identifies affected future processing and data-use permissions.
3. The responsible data steward confirms what can be stopped, deleted, retained by law, or cannot be technically undone.
4. The participant receives a clear status and an explanation of any limits.
5. The project must not claim that withdrawing consent automatically removes information already learned by a trained model. Any model unlearning or dataset removal requires separate technical validation and host-approved policy.

### D. Benefit-sharing
1. Community representatives define what benefits are meaningful and fair.
2. Each approved data-use project records relevant commitments.
3. The system reports whether commitments were fulfilled, without exposing participant identities.
4. Community representatives can contest or revise the process.

## 5. Security and privacy threat model

| Threat | Example | Candidate mitigation |
|---|---|---|
| Coercive consent | A person believes care depends on agreeing to AI research | Separate care from optional use; clear refusal route; facilitator training; complaint mechanism. |
| Re-identification | A pseudonymous record can be linked back to a person | Minimise fields; keep identity mapping outside the service; restrict access; assess linkage risks. |
| Excessive access | Staff or researchers view data beyond their role | Least privilege, purpose checks, short-lived access, audit review. |
| Insider misuse | An authorised user exports or repurposes records | Approval workflow, access logs, export controls, incident response. |
| Consent drift | Data use expands beyond the original explanation | Versioned purpose-specific permissions and re-review before new uses. |
| Incomplete withdrawal | A dataset copy or derived model remains in use | Data lineage, documented downstream duties, stop-future-use workflow, honest limits. |
| Data leakage in logs | Logs contain mental-health details or identifiers | Log metadata only; redact secrets and sensitive fields; restrict log access. |
| Digital exclusion | A participant cannot use a smartphone or read the interface | Assisted/offline alternatives, accessible formats, local-language review, non-digital route. |
| Governance capture | A small group controls rules without accountability | Representative community process, transparent criteria, rotation/appeals as locally appropriate. |

## 6. Ethical and operational gates

No pilot with real mental-health information should begin until all applicable gates have been satisfied:
- SRHIN confirms the problem and approves the scope.
- The affected communities participate in defining the rules and representation.
- The appropriate ethics review and local legal/data-protection review are complete.
- A data-flow map, threat model, retention schedule, and incident response plan are approved.
- Roles for data controller/steward, processors, community governance, and clinical oversight are clear.
- Participation and optional data-use consent are non-coercive and do not affect care.
- Languages, literacy, disability access, and non-digital participation routes are addressed.
- A process exists for complaints, safeguarding, and adverse events.
- The host approves any connection to GENCurate, GENSCORE, or other systems.

Early development and security testing should use synthetic data only. A synthetic test fixture must not be generated by copying or lightly altering real patient records.

## 7. Evaluation questions

Co-design evaluation measures with the host and participants. Candidate measures include:
- Can participants accurately explain the use(s) to which they agreed?
- Can a participant or authorised facilitator review and change a permission?
- Can the system prevent or flag a request outside an approved purpose?
- Can an auditor reconstruct who approved and accessed a dataset version?
- Can the service accurately show the status and limitations of a withdrawal request?
- Do community representatives consider the governance and benefit-sharing process fair and usable?
- Does the workflow add an acceptable amount of burden for participants and health workers?

Do not set a target number of participants or success percentage until SRHIN and the relevant ethics process approve a realistic pilot design.

## 8. Explicit non-goals

- No diagnosis, treatment recommendation, or replacement for a clinician.
- No new mental-health screening model.
- No central store of raw clinical narratives.
- No public release of identifiable or sensitive data.
- No claim of automatic deletion of model knowledge after withdrawal.
- No presumption that GENCurate or GENSCORE lacks features that already meet the need.
- No blockchain or tokenised benefit model by default.
