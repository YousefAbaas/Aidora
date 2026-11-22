# Provisional technical and ethical design — Community Data Use Passport

**Status:** Concept architecture only. It is not an approved SRHIN specification or a production design. Every component must be validated with the host and affected communities before implementation.

## 1. Design objective

Operationalise community-defined conditions for how mental-health data may be accessed, reused, and used in AI. The system should complement existing host tools and community-engagement resources; it must not duplicate data capture, transcription, screening, or clinical workflows.

The central technical object is a **versioned Data Use Manifest**: human-readable terms plus machine-readable rules associated with a data contribution, dataset version, or proposed use. A reference policy engine checks proposed use against those terms.

## 2. Architectural boundary

Participant / trusted facilitator  
→ Accessible choice and information interface  
→ Community governance workflow  
→ Data Use Manifest registry  
→ Policy evaluation API  
→ Host-approved data workflow adapter (only if authorised)  
→ Audit metadata and benefit-commitment status

The service should not store raw clinical narratives, screening results, recordings, or identity documents. It should hold the minimum policy and audit metadata needed to express and check agreed conditions. Even pseudonymous references may be personal data when they can be linked back to a person; the host must approve the data-flow and retention design.

## 3. Candidate components

### A. Manifest schema

A versioned JSON Schema and plain-language rendering. Candidate fields, subject to community and legal review:

| Field | Purpose | Boundary |
|---|---|---|
| Manifest ID and version | Identify the current rules | No direct personal identifier |
| Data/dataset reference | Point to an approved resource/version | Reference only; no copy of clinical data |
| Permitted purpose | Describe allowed use | No broad blanket permission |
| Prohibited purpose | Explicitly exclude unacceptable uses | Must be understandable and reviewable |
| AI activity | Distinguish training, evaluation, inference, publication, or secondary use | Each activity may have different conditions |
| Recipient class | Identify who may request or receive access | Community-approved categories |
| Retention and review date | Set time limits and review triggers | Must match host policy and applicable law |
| Required approvals | Route use to the authorised community/research body | Decision rights defined locally |
| Derivative and onward-use rules | State conditions for transformed datasets or model outputs | No promise of perfect downstream control |
| Withdrawal/change process | Describe prospective changes and technical limits | No false claim of automatic model unlearning |
| Benefit commitments | Record community-defined commitments, owners, and due dates | Community decides what counts as benefit |
| Notice and language version | Record which explanation was presented | Must support accessible formats |

Individual-level preferences and collective/community rules must be represented as separate but related authority layers. Applicable law and research ethics requirements remain independent requirements; the software does not decide whether consent is legally sufficient.

### B. Policy evaluation service

Input: a proposed use request containing requester role, stated purpose, intended AI activity, data/dataset reference, recipients, retention, and declared downstream use.

Output:
- **ALLOW** — request matches the active rules and required approvals;
- **DENY** — request conflicts with a prohibited purpose or other hard constraint;
- **REVIEW** — a human/community decision or missing evidence is required.

Each decision returns a reason code and manifest version. Default behaviour is fail closed when required policy information is missing or contradictory. This service only enforces rules inside systems that call it; it cannot prevent copying or use outside the integration boundary.

### C. Community governance workflow

A governance body or delegated representatives, selected by the affected community with SRHIN, can review new or secondary-use requests, apply conditions, reject a request, and record reasons and an appeal route. The system must not predefine who represents a community or assume one person speaks for all.

### D. Audit and benefit register

Record policy decisions, authorised approvals, access events supplied by an integrated system, withdrawal/change status, and benefit-commitment progress. Logs should be tamper-evident and access-controlled, but should not contain health narratives, unnecessary identifiers, tokens, or secrets. No blockchain or public ledger is proposed.

### E. Participant-facing access

A low-bandwidth, accessible view should explain current permissions and how to request changes. The interface may use Flutter, a web client, paper-assisted, or facilitator-supported alternatives; selection depends on participant needs and host systems, not developer preference.

## 4. Integration strategy

The first phase maps the actual SRHIN architecture and governance processes, including LEEF, its co-design guidance, GENSCORE and GENCurate as publicly described. The project will identify a single low-risk integration point only if SRHIN confirms one.

Possible integration patterns:
1. a policy-check API called before a dataset access or secondary-use request;
2. an exportable manifest attached to a governed dataset version;
3. a human-reviewed import/export workflow if the host cannot or should not expose a direct API.

Do not assume GENCurate or GENSCORE supports an extension point. Do not connect to production systems without written host authorisation and security review.

## 5. Security, privacy, and ethical safeguards

| Threat | Example | Candidate safeguard |
|---|---|---|
| Coercive participation | A person believes care depends on agreeing to AI research | Separate care from optional data use; accessible refusal and complaint path |
| Overbroad permission | One blanket consent permits unrelated future purposes | Purpose-specific, versioned terms and renewed review |
| Re-identification | A pseudonymous manifest reference is linked to identity | Data minimisation, segregated identity mapping, access controls, linkage-risk review |
| Excessive access | Researcher accesses data beyond approved scope | Least privilege, purpose checks, approval workflow, periodic audit |
| Consent drift | Data is reused after the original purpose changes | Version checks and review before every new use |
| Incomplete withdrawal | Copies or trained models remain after consent is changed | Prospective stop-use workflow, lineage where feasible, transparent limits; no automatic unlearning claim |
| Insider misuse | Authorised user exports data for a different purpose | Export controls, logging, incident response, governance review |
| Sensitive logs | Audit trail exposes a person's health information | Metadata-only events, redaction, restricted log access |
| Digital exclusion | Participant cannot use the app or read the language | Local-language and accessible formats, assisted/offline alternatives |
| Governance capture | A small group dominates community decisions | Locally agreed representation, conflict disclosure, review and appeal |

No pilot with real mental-health information begins until SRHIN has approved the scope, ethics review is complete, local legal/data-protection advice is obtained, security controls are assessed, and the community governance process is functioning. Synthetic data is the default for development and automated tests.

## 6. Twelve-month engineering plan

### Q1 — Discovery and requirements (June–August 2027)
- Map current SRHIN systems, policies, LEEF guidance, co-design procedures, data flows and decision rights.
- Hold host-approved, compensated discovery/co-design activities with the community groups SRHIN identifies.
- Agree the exact problem, success measures, safeguards and no-build conditions.
- Deliver a validated requirements brief, data-flow map, threat model and technical decision record.

### Q2 — Schema and alpha (September–November 2027)
- Publish a draft manifest schema and plain-language template.
- Implement a minimal Django REST API, manifest registry and deterministic policy evaluator.
- Implement allow/deny/review test cases with synthetic fixtures.
- Deliver an alpha, API documentation, automated tests and initial security review.

### Q3 — Controlled integration and evaluation (December 2027–February 2028)
- Build one limited adapter or controlled import/export path if the host approves.
- Test permissions, versioning, audit metadata, accessibility, and withdrawal/change workflows.
- Run security, usability, and policy-conformance tests in staging with synthetic or expressly approved de-identified data.
- Deliver a beta and evaluation findings.

### Q4 — Approved pilot and public release (March–May 2028)
- Pilot only if ethics, host, legal, security and community approvals are complete.
- Evaluate participant understanding, decision traceability, handling of out-of-scope requests, burden, and benefit-commitment status.
- Release code, schema, API specification, deployment guide and a community-reviewed report without sensitive data.
- Deliver a maintenance and governance plan.

## 7. Evaluation framework

Baselines and targets must be set with SRHIN and participants in Q1. Candidate indicators:
- participant comprehension of specific data uses and available choices;
- number/proportion of out-of-scope requests blocked or escalated before access;
- completeness of decision records and manifest-version traceability;
- time and staff effort to review a secondary-use request;
- ability to record and communicate the status and limits of change/withdrawal requests;
- proportion of benefit commitments with named owners, due dates and recorded status;
- participant and community assessment of fairness, trust, and practical burden.

Do not invent numeric targets before discovery. Document adverse findings and cases where the policy engine cannot enforce a condition.

## 8. Technical choices and non-goals

Candidate stack: Python, Django REST Framework, PostgreSQL, and an accessible web or mobile interface. This reuses the applicant's relevant engineering experience from Aidora, but the host may require a different stack or an integration that avoids deep coupling.

Non-goals:
- no mental-health diagnosis, treatment advice, or screening model;
- no replacement for GENSCORE, GENCurate, or clinical systems;
- no central repository of raw patient records;
- no automatic promise that model knowledge can be erased after withdrawal;
- no publication of identifiable or sensitive data;
- no blockchain, token, or monetisation scheme by default;
- no claim that software alone solves structural power imbalances.

## 9. Open-source and sustainability plan

Release the reusable schema, reference implementation, tests, documentation, and non-confidential learning openly under licences agreed with Mozilla and the host. Keep sensitive data, security details that could enable abuse, and confidential host information private. Provide a self-hosting guide, minimal deployment profile, versioning policy, contribution guide, and named maintenance pathway.

The project is successful only if communities and independent organisations can understand, govern, adapt, and maintain the tool—not merely if a prototype is demonstrated.
