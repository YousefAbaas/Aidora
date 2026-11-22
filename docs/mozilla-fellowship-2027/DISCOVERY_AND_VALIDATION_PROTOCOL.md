# Host discovery and technical-gap validation protocol

**Status:** Preparation protocol only. No SRHIN internal information, community research, or host-approved discovery has taken place. Use only after SRHIN agrees to an exploratory process and defines the appropriate contacts and safeguards.

## 1. Purpose

Determine whether a specific, consequential technical hand-off gap exists between SRHIN's existing community-governance decisions and one downstream data/AI workflow—and whether a small open technical contribution would improve accountability without duplicating existing tools.

This protocol is deliberately designed to allow three legitimate outcomes:

- **Build:** evidence supports a narrow, host-approved technical integration.
- **Adapt:** an existing SRHIN or open-standard tool can be configured, documented, or connected with little or no new code.
- **No-build / pivot:** existing processes already address the issue, the gap is not important enough, or software is not the right intervention.

A no-build decision is a successful discovery outcome if it prevents unnecessary technology.

## 2. Non-negotiable boundaries

1. SRHIN determines whether discovery is welcome, who may participate, and which workflows may be discussed.
2. SRHIN and affected communities—not the applicant—identify legitimate decision-makers and the distribution of authority.
3. Do not contact community members independently or recruit participants without host approval.
4. Do not collect personal, health, mental-health, displacement, consent, or other sensitive information during informal discovery.
5. Do not request production data, credentials, internal diagrams, API keys, or access to SRHIN systems at the exploratory stage.
6. Use public documentation and synthetic examples by default. Any later research or real-data access requires appropriate host, community, ethics, legal, privacy, safeguarding, and security approvals.
7. Do not assume GENSCORE, GENCurate, or any other SRHIN system has an API, extension point, or integration gap.
8. Do not recreate SRHIN's LEEF checklist, AI co-design guide, compensation/governance template, Epistemic Authority Decision Matrix, or co-production readiness tool.
9. Do not treat a digital log as proof that a community decision was legitimate, that a benefit was fair, or that a contractual obligation was enforced.
10. Do not claim host endorsement, community co-design, or validation until it actually occurs and can be described accurately.

## 3. Public-work baseline to map before proposing software

For each relevant item, record only what its public documentation establishes, what remains unknown, and what SRHIN says is current:

| Asset / process | Discovery question | Do not assume |
|---|---|---|
| LEEF checklist | At what stage is it used, by whom, and how are its decisions carried forward? | That a checklist is an executable control or that it is insufficient |
| Lived-experience AI co-design guide | How are participation and influence operationalised in project decisions? | That participation automatically grants decision authority |
| Compensation/governance template | How are community-defined commitments approved, tracked, challenged, and fulfilled? | That a new compensation register is needed |
| Epistemic Authority Decision Matrix | How is authority assigned, recorded, revisited, and applied to downstream use? | That the matrix should be reimplemented in software |
| Co-Production Readiness Self-Assessment | How do readiness findings change project approval or delivery? | That another assessment tool adds value |
| GENSCORE | Which data/AI lifecycle stages are relevant to the proposed challenge? | Any API, data model, deployment details, or integration permission |
| GENCurate | Which capture, curation, analysis, and governance controls already exist? | That it is the target integration point |
| Consent, data-use agreements, access and review processes | What is authoritative, who approves changes, and how are conditions enforced today? | That published resources fully describe internal practice |

## 4. Host-led discovery questions

Ask only questions SRHIN considers appropriate. Start with the workflow, not with a proposed product.

### A. Workflow and existing controls
- Can the team describe one representative, non-sensitive example of a data/AI use request from proposal through approval, access, use, review, and closure?
- Which systems, agreements, policies, and people are authoritative at each stage?
- Where are community decisions recorded, and how are those decisions communicated to data stewards, researchers, and technical systems?
- What happens when a proposed use changes, a permission expires, a participant raises a concern, or a community decision is revised?
- Which controls are automated, which are manual, and which rely on contractual or organisational processes?

### B. Community authority and accountability
- Who determines which community representatives or governance bodies hold authority for a particular decision, and how is that legitimacy reviewed?
- How can people disagree, appeal, withdraw, or request a change without losing access to care or services?
- How are conflicts of interest, unequal representation, accessibility, and offline participation handled?
- Who defines acceptable benefits, and what process exists when commitments are disputed or not fulfilled?

### C. Technical gap and consequences
- Is there a point where an approved community decision is lost, weakened, delayed, or not visible to the next actor or system?
- Has this caused a concrete risk, delay, repeated manual work, or accountability failure? What evidence can be shared safely?
- Is the problem primarily technical, organisational, contractual, educational, or resourcing-related?
- What is the smallest intervention that would materially improve the situation?
- What would make a software intervention harmful, burdensome, or unnecessary?

### D. Fellowship feasibility
- Would SRHIN consider an independent Embedded Fellow project in this area?
- Who would supervise the work and provide technical, clinical, ethics, and community guidance?
- What working hours, response times, travel, and in-person commitments are expected?
- What can be completed remotely, and what depends on local presence?
- What outputs would SRHIN consider genuinely useful after 12 months?

## 5. Technical gap evidence record

For each candidate gap, record:

| Field | Required evidence |
|---|---|
| Workflow boundary | Exact stage where the hand-off occurs |
| Existing mechanism | Current policy, agreement, tool, system, and responsible role |
| Failure mode | Specific example of information or authority being lost, weakened, delayed, or made unreviewable |
| Consequence | Who is affected and what risk or burden results |
| Frequency / materiality | Evidence of recurrence or seriousness; do not invent numbers |
| Community view | How affected people define the problem and its importance, using a host-approved process |
| Non-software alternatives | Training, agreement changes, workflow changes, staffing, or existing-tool configuration |
| Standards fit | Whether DUO, GA4GH Passports/Data Passports, ODRL, or another existing standard is relevant and semantically accurate |
| Integration boundary | One approved point where a check or trace could help; no assumed API |
| Data minimisation | Minimum metadata required; avoid sensitive payloads and linkable identifiers |
| Ownership and maintenance | Who controls, operates, reviews, and retires the integration |
| Evidence status | Publicly documented, host-confirmed, community-validated, or still unknown |

A problem statement is not validated merely because it is technically interesting or because an integration can be built.

## 6. Build / adapt / no-build decision rubric

### Build only if all are true
- SRHIN confirms the workflow and a material gap.
- Affected communities validate that the issue matters and retain meaningful decision authority.
- Existing host resources and standards do not already solve it adequately.
- A narrowly scoped integration can reduce a defined risk or burden.
- The integration point, data boundary, security requirements, and accountable owner are approved.
- The work is feasible within the Fellowship period and does not depend on unapproved real-data access.

### Adapt an existing tool if
- The gap is real but an existing SRHIN system, standard, or maintained open-source tool can address it through configuration, mapping, documentation, or a controlled hand-off.
- The adaptation has a clear maintainer and does not fork or duplicate governance policy unnecessarily.

### Choose no-build / pivot if
- Existing processes already address the problem.
- The issue is primarily organisational, legal, contractual, or resource-related rather than technical.
- Community members do not want the proposed intervention.
- The tool would create surveillance, coercion, exclusion, or new privacy risks.
- There is no safe, authorised integration boundary or sustainable maintainer.
- The benefit cannot be demonstrated without disproportionate data collection or burden.

## 7. Candidate minimum technical deliverable (conditional)

If—and only if—the build gate is passed, the first demonstrator should be limited to:

- one host-approved workflow boundary;
- one documented mapping to an existing standard, only where semantics match;
- one synthetic example dataset;
- one policy decision response: ALLOW, DENY, or REVIEW;
- explicit reason codes, policy version, and provenance;
- fail-closed behaviour for missing, expired, contradictory, or unmapped conditions;
- human/community review path;
- automated tests for allowed, prohibited, expired, changed, missing, and ambiguous conditions;
- documented limits: the check governs only systems that invoke it and cannot prevent copying or use outside the integration boundary.

Do not build a new participant portal, consent-management platform, governance framework, payment system, or central health-data store as a default.

## 8. Deliverables for the discovery phase

1. A public-resource and host-confirmed workflow map, with confidential details excluded.
2. An inventory of existing controls and the responsible owner at each stage.
3. A gap register with evidence and unresolved assumptions.
4. A community-approved statement of the problem and decision rights, if discovery is authorised.
5. A standards-fit table that identifies where existing standards do and do not apply.
6. A build/adapt/no-build recommendation with explicit reasons.
7. A concise ethics, privacy, security, accessibility, and maintenance risk register.

## 9. Exit criteria

Discovery is complete only when SRHIN can answer:

- What exact workflow is being improved?
- What existing control currently handles it?
- What fails or remains costly, and who says so?
- Who has authority to approve the proposed intervention?
- Why is software better than changing an existing process?
- What is the minimum safe data flow?
- Who will maintain and govern the result?
- What evidence will show that the intervention helped rather than added burden?

If these questions cannot be answered, do not move to implementation.

## 10. Relationship to the application

This protocol strengthens the proposed Fellowship plan; it does not claim discovery has already occurred. The Letter of Intent must describe the project as a hypothesis and explain that Q1 will validate the need. Any later claims about SRHIN systems, community decisions, or technical gaps must be attributed to the appropriate host-approved evidence and reviewed before publication.
