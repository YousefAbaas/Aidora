# Provisional technical and ethical design — Community Governance Layer for Health-AI Data Use

**Status:** Concept architecture only. It is not an approved SRHIN specification or production design. All components require host and community validation.

## 1. Design objective

Investigate whether community-defined governance decisions and benefit commitments can be represented and operationalised using existing open standards, rather than inventing a new data-use ontology or passport.

Candidate standards include:
- **GA4GH DUO** for standardised, machine-readable data-use terms;
- **GA4GH Passports / Data Passports** for researcher authorisation and data-level policy attributes, subject to their scope and maturity;
- **GA4GH Machine-Readable Consent Guidance** for mapping consent language to DUO;
- **W3C ODRL 2.2** for expressing permissions, prohibitions, constraints, and duties.

These standards have different purposes and are not automatically interchangeable. Q1 must assess their suitability for SRHIN's mental-health data workflows and document gaps. The project must not claim to replace them.

## 2. Provisional architecture

Affected person / trusted facilitator  
→ accessible explanation and choice support  
→ community-defined governance and review process  
→ existing host consent, data-use, and access systems  
→ standards mapping / profile only where needed  
→ host-approved policy check at one workflow boundary  
→ audit metadata and benefit-commitment status

The service should not store raw clinical narratives, screening results, recordings, or identity documents. It should hold only the minimum policy and audit metadata approved by SRHIN. Even pseudonymous references may be personal data if linkable; the host must approve data flows and retention.

## 3. Discovery and standards mapping

Before implementation, produce a matrix with:
- SRHIN workflow and existing system;
- the community decision or obligation that must be represented;
- current legal, ethical, contractual, and technical control;
- candidate standard (DUO, GA4GH Passports/Data Passports, ODRL, or none);
- semantic fit and known limitation;
- whether an adapter, profile, governance process, or no new software is required.

The standards mapping must answer:
1. Can DUO express the relevant permitted-use category, or is the issue actually a governance decision rather than a vocabulary term?
2. Can GA4GH Passports/Data Passports represent the relevant researcher or data-level policy attribute in the intended environment?
3. Can ODRL express the relevant permission, prohibition, constraint, or duty without inventing ambiguous semantics?
4. Which community rights—such as collective approval, appeal, contestation, or benefit-sharing oversight—are not adequately represented by the existing workflow?
5. Can those gaps be addressed through agreements and governance rather than additional software?

No new ontology or universal passport is a deliverable by default.

## 4. Candidate technical components — only if the gap is validated

### A. Standards adapter

A small, versioned mapping layer may translate host-approved policy fields into DUO terms or ODRL expressions where the meaning is genuinely equivalent. It must preserve provenance and flag any field that cannot be represented without loss. It must never silently convert a community decision into a weaker permission.

### B. Governance workflow

A host-approved workflow may support:
- submission of a proposed secondary use;
- routing to the community-designated reviewer or committee;
- approve, reject, condition, or request-more-information decisions;
- reason capture, conflict-of-interest declaration, expiry, and appeal;
- a traceable record of the governing policy version.

The affected community and SRHIN define who holds decision authority. The software must not invent representation or assume one individual speaks for everyone.

### C. Policy check

A narrow policy-check API may return:
- **ALLOW** — the request matches active conditions and required approvals are present;
- **DENY** — it conflicts with an explicit prohibition or hard constraint;
- **REVIEW** — human/community decision or missing evidence is required.

Every response should include a reason code, policy/manifest version, and provenance. Missing or contradictory information should fail closed. It can enforce conditions only within systems that call it; it cannot prevent copying or use outside those integration boundaries.

### D. Benefit-commitment record

Record community-defined commitments, the responsible party, due date, evidence of delivery, review status, and a route to contest non-delivery. This is an accountability record, not a payment system or guarantee of legal enforcement. Benefit types and acceptable evidence must be defined by the community.

### E. Accessible explanation and challenge

Provide plain-language explanations of proposed use, the decision route, current status, and how to raise a concern. Test language, literacy, disability access, low-bandwidth, and assisted/offline needs with the community. Do not assume an app is the right interface.

## 5. Security, privacy, and ethical safeguards

| Threat | Example | Candidate safeguard |
|---|---|---|
| Coercive participation | A person believes care depends on agreeing to AI research | Separate care from optional use; accessible refusal and complaint route |
| Overbroad permission | One blanket consent permits unrelated future purposes | Purpose-specific conditions and renewed review |
| Standards mismatch | Adapter maps a community condition to an inaccurate DUO/ODRL term | Human-reviewed mappings, provenance, conformance tests, explicit unmapped state |
| Governance capture | A small group dominates decisions | Locally agreed representation, conflict disclosure, review, appeal |
| Re-identification | A pseudonymous policy reference is linked to identity | Data minimisation, segregated identity mapping, linkage-risk review |
| Excessive access | Researcher accesses data beyond approved scope | Least privilege, policy checks, approval workflow, periodic audit |
| Consent drift | Data is reused after purpose changes | Version checks and review before new use |
| Incomplete withdrawal | Copies or trained models remain after consent changes | Prospective stop-use workflow, lineage where feasible, transparent limits; no unlearning guarantee |
| Sensitive logs | Audit trail exposes health information | Metadata-only events, redaction, restricted log access |
| Digital exclusion | Participant cannot use app or read the language | Local-language formats and assisted/offline alternatives |

No real-data pilot begins until SRHIN approves the scope, ethics review is complete, local legal/data-protection advice is obtained, security controls are assessed, and the community governance process is functioning. Synthetic data is the default for development and automated tests.

## 6. Integration strategy

The project should select one low-risk workflow only after mapping the host's actual architecture. Possible patterns:
1. call an approved policy-check endpoint before a secondary-use request;
2. attach a standards-aligned policy representation to an approved dataset/version;
3. use a controlled human-reviewed import/export process if a direct integration is unsuitable.

Do not assume GENSCORE or GENCurate exposes an extension point. No production connection without written host authorisation and security review.

## 7. Twelve-month engineering plan

### Q1 — Discovery and standards fit (June–August 2027)
- Map SRHIN systems, policies, LEEF guidance, co-design processes, data flows, and decision rights.
- Conduct host-approved, compensated discovery with community groups identified by SRHIN.
- Compare requirements against DUO, GA4GH Passports/Data Passports, ODRL, and relevant host controls.
- Deliver a gap analysis and a build/adapt/no-build decision.

### Q2 — Specification and alpha (September–November 2027)
- If a gap is validated, specify a minimal governance workflow and standards mapping.
- Build an alpha adapter or workflow with synthetic data.
- Add automated conformance, policy, and security tests.
- Deliver documentation of semantic limitations and unresolved requirements.

### Q3 — Controlled integration and evaluation (December 2027–February 2028)
- Implement one host-approved staging integration or controlled import/export path.
- Test access decisions, versioning, audit metadata, accessibility, and change/appeal processes.
- Conduct security, usability, and policy-conformance tests.

### Q4 — Approved pilot and open release (March–May 2028)
- Pilot only after host, community, ethics, legal, privacy, and security approvals.
- Evaluate participant understanding, decision traceability, challenge/appeal handling, operational burden, and benefit-commitment status.
- Release reusable mappings, code, tests, implementation guidance, and a community-reviewed report without sensitive data.

## 8. Evaluation framework

Baselines and targets must be set with SRHIN and community participants in Q1. Candidate indicators:
- participant understanding of data-use choices and routes to challenge decisions;
- proportion of requests blocked or escalated before access when conditions are unmet;
- traceability of the policy version, decision authority, and reasons;
- community assessment of legitimacy and accessibility of review/appeal;
- benefit commitments with named owners, due dates, and recorded evidence/status;
- mapping accuracy and interoperability with existing standards;
- staff and participant burden.

Do not invent numeric targets before discovery. Report limitations and adverse findings.

## 9. Technical choices and non-goals

Candidate implementation stack: Python, Django REST Framework, PostgreSQL, and an accessible web/mobile interface. This draws on the applicant's experience with Aidora, but the host's architecture and needs determine the final stack.

Non-goals:
- no new universal data-use ontology or passport by default;
- no mental-health diagnosis, treatment advice, or screening model;
- no replacement for GENSCORE, GENCurate, or clinical systems;
- no central repository of raw patient records;
- no guarantee of automatic model unlearning or control beyond integration boundaries;
- no publication of identifiable or sensitive data;
- no blockchain, token, or monetisation scheme by default;
- no claim that software alone solves structural power imbalances.

## 10. Open-source and sustainability

Prefer contributions to existing standards and upstream communities where appropriate. Publish any host-approved adapter, mappings, tests, documentation, and non-confidential learning under licences agreed with Mozilla and SRHIN. Provide self-hosting and maintenance guidance. Keep sensitive data, confidential host information, and security-sensitive details private.

The project succeeds only if it improves community agency and accountability in a real workflow—not merely if code is shipped.
