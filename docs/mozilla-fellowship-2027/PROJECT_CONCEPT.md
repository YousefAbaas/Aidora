# Project concept — Community-Controlled Governance for Mental-Health Data

**Working title:** Community-Controlled Governance Layer for Mental-Health Data  
**Preferred route:** Mozilla Foundation Track I — Embedded Fellow  
**Potential host:** Slum & Rural Health Initiative (SRHIN), Nigeria  
**Status:** Applicant-generated concept for discussion. Not approved by SRHIN and not yet co-designed with the communities concerned.

## 1. The challenge to explore

Mozilla's 2027 Fellowship RFP describes a specific challenge for SRHIN: mental-health data from African communities is increasingly used to build AI without meaningful consent, community control, or a fair share of the benefits. The RFP says the priority is to explore community-owned tools for governance, consent, privacy, and benefit-sharing, and to pilot with young people, people with lived experience, and community health workers.

SRHIN's public material describes GENSCORE as work combining AI, lived experience, and local knowledge to develop culturally grounded mental-health screening. It describes GENCurate as a platform for capturing, transcribing, and analysing patient data. This means the proposal should not duplicate data collection, transcription, screening, or clinical workflow software.

**The initial hypothesis (to validate, not to assume):** existing data and AI workflows may need a transparent, community-governed way to record what uses people have agreed to, who may access data for which purposes, how downstream use is audited, how a participant's choices can be changed, and how community benefit commitments are made visible.

The first phase must map SRHIN's actual systems, policies, research protocols, and community governance arrangements. If these needs are already adequately addressed, the project must change direction or stop rather than build a redundant tool.

## 2. Proposed response

Explore and, only if the host and communities confirm the need, build a small open-source **data-governance layer** that can sit alongside an existing health-data workflow such as GENCurate/GENSCORE.

The layer would focus on governance metadata and decisions, not on holding mental-health narratives or replacing clinical systems. It could help participants and community representatives understand and manage permitted data uses, while allowing authorised stewards and researchers to demonstrate that their use of data follows the agreed conditions.

### Candidate capabilities

1. **Purpose-specific permissions:** record the purposes for which a defined data contribution may be used (for example, service delivery, research, model development, or a named study), with plain-language explanations.
2. **Participant-facing controls:** allow a participant to review the current permission record, ask questions, change future permissions, or withdraw consent through an accessible process.
3. **Community governance workflow:** allow a community-designated governance group to review proposed secondary uses and record decisions, conditions, and reasons.
4. **Data-use audit trail:** record approved requests, access events, dataset versions, and downstream-use declarations, without exposing the participant's sensitive content.
5. **Withdrawal and retention workflow:** record what must stop, what can be deleted, what has already been shared, and what limitations remain for data or models already derived from a contribution.
6. **Benefit-sharing register:** document community-approved benefit commitments and whether they were delivered. The project should not assume that benefit-sharing must be monetary.
7. **Interoperable interface:** provide a documented API or adapter only after SRHIN's technical team confirms the relevant integration point and permissions.

## 3. How it differs from the existing public-facing tools

| Existing public description | Proposed project boundary |
|---|---|
| GENCurate captures, transcribes, and analyses patient data. | Does not rebuild patient-data capture or transcription; investigates governance around permitted use and access. |
| GENSCORE explores culturally grounded mental-health screening using AI, lived experience, and local knowledge. | Does not create a screening model, diagnose, or replace clinicians; focuses on the rules and evidence around data use. |
| SRHIN's work involves researchers, clinicians, linguists, and people with lived experience. | Seeks to make community-defined data-use conditions operational and reviewable, under their direction. |

These are summaries of public descriptions, not a technical audit of either platform. The proposed layer may be unnecessary if current systems already satisfy the identified need. No integration is promised before technical discovery and host approval.

## 4. Agency, Commons, and economic conditions

### Agency — people have meaningful control

The design should make permission understandable, specific, revisable, and non-coercive. Declining secondary research or AI use must not affect access to care or services. Community representatives must help define the rules and the process for handling disputes.

### Commons — open infrastructure, not open sensitive data

The software, schemas, documentation, and reusable governance methods should be openly licensed where rights permit. Identifiable or sensitive mental-health data must never be published merely to make the project “open.” Any dataset sharing requires a separate, explicit, community-approved and ethically reviewed basis.

### Economic conditions — fairer terms for data use

The project will explore how community-defined terms, transparent data-use records, and benefit-sharing commitments can reduce extractive arrangements. It should not claim that a software tool alone solves unequal bargaining power. Evidence of changed practice must come from the host and community pilot.

## 5. A realistic 12-month outcome

By the end of the Fellowship, a successful project could leave:
- a community-approved governance and consent workflow;
- a tested open-source prototype for consent and data-use governance metadata;
- a documented API/schema that can interoperate with an existing platform if SRHIN approves;
- a threat model, privacy review, accessibility/language findings, and implementation documentation;
- a pilot evaluation co-authored or reviewed by community representatives;
- a practical guide that other community health or research organisations can adapt.

The project should use synthetic or fully de-identified test records during early development. Any pilot involving real participant data is conditional on the host's approval, community governance, ethics review, local legal review, safeguarding arrangements, and an appropriate data-protection plan.

## 6. Proposed quarterly milestones

**Quarter 1 — Listen and map.** Work with SRHIN's technical team and community partners to map existing GENSCORE/GENCurate workflows, consent practices, data flows, existing governance, language/accessibility needs, and unresolved gaps. Agree research and safeguarding protocols. Produce a jointly validated problem statement and scope.

**Quarter 2 — Co-design and prototype.** Co-design participant journeys and governance rules. Build a minimal consent/permission registry, governance-review workflow, and audit-event model using synthetic data. Publish an initial open technical specification.

**Quarter 3 — Integrate and test.** If SRHIN approves the interface, build a limited adapter or import/export workflow. Test security, usability, accessibility, and withdrawal workflows in a staging environment. Do not connect to live sensitive data until all approvals are in place.

**Quarter 4 — Pilot and release.** Conduct a host-approved pilot with the agreed participants and safeguards. Evaluate comprehension, control, traceability, and operational burden. Release reusable code and documentation under an agreed open licence, and publish a community-reviewed report that excludes identifiable data.

## 7. Why the applicant could contribute

The applicant's relevant technical evidence is Aidora, a full-stack academic project built primarily by the applicant using Flutter/Dart, Django REST Framework, PostgreSQL, REST APIs, authentication, role-aware workflows, and client/server integration. These are transferable engineering skills for building permissions, workflow, and audit interfaces.

The applicant does not claim prior expertise in clinical mental-health research, African community data governance, or SRHIN's systems. Those are areas for learning from the host, its technical and clinical staff, and the people whose data and experiences are involved. The application must explain why the applicant is motivated to do this work and what specific learning or lived experience they bring, in their own words.

## 8. Critical assumptions to test before committing

- Does SRHIN see a real gap around consent, secondary use, withdrawal, auditability, or benefit-sharing that is not already solved by GENCurate, GENSCORE, policy, or existing processes?
- Would SRHIN consider an applicant working remotely from outside Nigeria, with a workable time difference?
- Which community groups would want to shape the work, and how should they be represented and compensated for their time?
- What local ethics approvals, data-protection rules, clinical safeguards, and institutional permissions apply?
- Who would maintain the software and govern changes after the Fellowship?
- Can the applicant legally receive and use grant funds in the country where they will reside and work?

If these assumptions cannot be answered positively, do not submit a proposal claiming a host fit or a deliverable that depends on unavailable access.
