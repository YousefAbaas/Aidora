# Project concept — Community-Controlled Data Use Passport for Health AI

**Working title:** Community-Controlled Data Use Passport for Health AI  
**Track under consideration:** Mozilla Foundation Track I — Embedded Fellow  
**Potential host:** Slum & Rural Health Initiative (SRHIN), Nigeria  
**Status:** A proposed direction for discussion. It is not approved by SRHIN, not co-designed with Nigerian communities, and not yet a working product.

## 1. The opportunity — and the question we must validate

Mozilla's 2027–2028 RFP identifies a challenge for SRHIN: mental-health data from African communities is increasingly used to build AI without meaningful consent, community control, or a fair share of benefits. It calls for exploring community-owned tools for governance, consent, privacy, and benefit-sharing, and piloting with young people, people with lived experience, and community health workers.

This must not be interpreted as evidence that SRHIN lacks community engagement or responsible-design practices. SRHIN publicly describes co-creation with people with lived experience and publishes resources including the LEEF pre-launch checklist and a guide for involving people with lived experience in AI mental-health tool design. It also describes existing digital-health and AI work, including GENSCORE and GENCurate.

**The hypothesis to test with SRHIN is narrower:** even where strong community-engagement principles and consent practices exist, are community-defined conditions reliably carried forward and checked when data is accessed, reused, linked, shared, or used to train or evaluate AI systems? Can the people and community bodies who set those conditions see whether they were followed and whether agreed benefits were delivered?

The first stage must map SRHIN's existing tools, LEEF guidance, consent notices, data-use agreements, research governance, technical controls, and community decision-making. If the proposed gap is already adequately addressed, the project must change direction or stop. It must not create a duplicate tool simply to produce software.

## 2. The proposed innovation

Explore and, only if SRHIN and affected communities validate the need, build an open **Community Data Use Passport**: a human-readable and machine-readable set of community-approved conditions associated with a defined dataset version, data contribution, or proposed use.

The Passport is not a consent form and not a repository of clinical records. It makes agreed conditions legible to people and systems, then provides a small reference implementation that can check proposed data uses against those conditions.

A versioned, portable policy manifest could express:
- permitted and prohibited purposes, including whether AI training, evaluation, or secondary research is allowed;
- approved recipient categories and any approval required before onward access;
- scope, duration, retention, and review conditions;
- conditions applying to derived datasets, model development, publication, or onward sharing;
- how individual preferences and community-level governance decisions interact;
- withdrawal and change requests, including what can and cannot be reversed once data has been shared or used;
- community-defined benefit commitments, responsible parties, and evidence of delivery.

A policy-checking service would evaluate proposed uses against the manifest. It would allow, block, or route a request for human/community review; record the decision and relevant audit metadata; and show whether benefit commitments are due or fulfilled. Only systems that integrate with the policy interface can enforce the rules technically, so the project must be explicit about integration boundaries and residual risks.

## 3. Fit with SRHIN's existing work

The proposal is designed to complement, not replace:
- **LEEF:** learn from and build on SRHIN's published lived-experience pre-launch checklist rather than inventing another engagement framework;
- **the lived-experience AI co-design guide:** use it as a starting point for meaningful participation and accessible design;
- **GENSCORE:** do not build another mental-health screening model or diagnostic tool;
- **GENCurate:** do not rebuild patient-data capture, transcription, or analysis; explore governance around permitted downstream use only if discovery identifies a gap.

Public descriptions are not a technical audit. The first deliverable is a joint map of what already exists and what, if anything, remains missing.

## 4. Who it is for

Potential users, to be confirmed by SRHIN and the communities involved:
- young people and adults with lived experience whose data may contribute to mental-health research or AI;
- community health workers and trusted facilitators who explain choices and support participation;
- community-designated data stewards or governance representatives who review proposed uses;
- researchers and technical teams who need to demonstrate that a proposed use follows agreed conditions.

Participation must be voluntary and accessible. Declining optional research or AI use must not reduce access to care or services. The project will not assume that a single community representative can speak for everyone.

## 5. Mozilla's three investment questions

### Agency — does it put people in control?

The goal is to make choices understandable, specific, revisable, and reviewable. Individual permissions and community-level rules are distinct layers; neither should silently override the other. Participants should be able to understand the purpose of a proposed use and seek a change or withdrawal through an accessible route. Community-designated governance bodies should have the authority defined by the community to approve, reject, condition, or revisit secondary-use requests.

### Commons — does it cultivate open infrastructure?

The schema, reference implementation, API specification, governance workflow templates, and non-confidential documentation should be openly available under licences agreed with Mozilla and the host. The Passport should be portable enough to be adopted by more than one platform, not tied to a proprietary vendor. **Open infrastructure does not mean open health data:** no identifiable or sensitive records will be published.

### Economic conditions — can it change how markets work?

The project will make community-defined conditions and benefit commitments visible and auditable, so communities are better equipped to negotiate how their data is used and what they receive in return. Benefits may be non-monetary and must be defined by the community. The project will not claim that a software tool alone corrects unequal bargaining power; it will test whether transparent, reusable conditions improve accountability and negotiating capacity.

## 6. What would be built

Subject to host and community validation, a deliberately small technical scope:

1. **Policy manifest schema:** a versioned JSON schema with a plain-language rendering; no identity details or clinical narratives.
2. **Governance API:** endpoints to register a manifest, submit a proposed data-use request, record an authorised decision, and retrieve its current status.
3. **Policy evaluation service:** deterministic checks that return allow, deny, or human-review-required, with reasons.
4. **Governance workflow:** roles and review steps selected by the community, with reasons, conditions, appeals, and expiry.
5. **Audit and benefit register:** protected metadata showing requests, approvals, relevant access events, and the status of agreed benefit commitments.
6. **Accessible participant view:** a low-bandwidth, plain-language view of the permissions and process; the final interface and languages will be selected with SRHIN and participants.

The governance service should store the minimum metadata required. Identity mapping and raw clinical records should remain in host-approved systems, not be copied into this layer. A portable manifest can express conditions, but a receiving system that does not implement the policy checks may ignore them; this limitation must be explained and addressed through agreements, monitoring, and governance.

## 7. A realistic 12-month pathway

**Q1 — Discover and agree (June–August 2027).** Map SRHIN's existing systems, LEEF and co-design processes, consent practices, data flows, governance arrangements, and benefit-sharing expectations. Co-design with the groups SRHIN identifies. Deliver a jointly validated problem statement, system map, requirements, and ethics/safeguarding plan. A no-build decision is acceptable if the gap is not real.

**Q2 — Specify and prototype (September–November 2027).** Publish a draft policy-manifest schema and governance workflow. Build an alpha policy engine and API using synthetic data. Test allow/deny/review cases and document the threat model and integration boundary.

**Q3 — Integrate and evaluate (December 2027–February 2028).** If the host approves, build a limited staging adapter to one selected workflow. Conduct accessibility, usability, security, and policy-conformance testing with synthetic or approved de-identified records. Revise rules with community governance representatives.

**Q4 — Governed pilot and open release (March–May 2028).** Run a host-approved pilot only after all ethics, legal, privacy, safeguarding, and security gates are met. Evaluate participant understanding and control, decision traceability, handling of out-of-scope requests, operational burden, and benefit-commitment tracking. Release the reusable code, schema, implementation guide, and a community-reviewed report without sensitive data.

## 8. How success will be measured

The host and community participants should set baselines and targets in Q1. Candidate measures include:
- whether participants can explain the purposes they have agreed to and where to ask for changes;
- whether requests outside permitted purposes are blocked or escalated before access;
- whether a reviewer can reconstruct the decision, conditions, and responsible authority;
- whether withdrawal requests are tracked honestly, including technical limits;
- whether community-defined benefit commitments have named owners, deadlines, and evidence of delivery;
- whether the workflow is understandable and adds an acceptable burden for participants and staff.

No participant count, success percentage, or impact claim should be invented before the host and ethics process approve a realistic pilot.

## 9. Why the applicant can contribute

The applicant created and owns Aidora and led its end-to-end technical design and principal implementation: Flutter/Dart mobile client, Django REST Framework backend, PostgreSQL, REST APIs, authentication, role-aware workflows, integration, tests, and GitHub Actions delivery automation. This is evidence of transferable software-building capability for an API, workflow, and policy-checking prototype.

The applicant does not claim prior expertise in clinical mental-health research, Nigerian community data governance, or SRHIN's internal systems. He will rely on SRHIN's technical, clinical, ethics, and community expertise to shape the requirements and will treat the community as decision-makers, not as a testing pool.

The applicant's earlier work on Aidora included direct conversations with refugees and people seeking assistance, with positive initial feedback during the project's launch. This is a relevant early qualitative learning experience, not evidence of formal co-design, a measured user base, or impact in Nigeria.

## 10. Conditions that must be satisfied

- SRHIN confirms a specific unmet governance need after reviewing existing tools and practices.
- SRHIN is willing to consider the applicant for an Embedded Fellowship and to support a community-led process.
- The community groups, decision-making authority, compensation, and safeguarding approach are agreed.
- Applicable ethics review, data-protection/legal review, and security approvals are in place before any real-data pilot.
- Early development uses synthetic data; de-identified data is used only with explicit approval and a documented risk assessment.
- The applicant's location, time-zone flexibility, legal ability to receive funds, and bank transfer route meet Mozilla's eligibility requirements.
- The prototype can be maintained and independently used after the Fellowship.

## 11. References to validate during discovery

- Mozilla 2027–2028 Fellowship RFP: https://assets.mofoprod.net/network/documents/PUBLIC_2027_2028_Fellowship_RFP-3.pdf
- SRHIN LEEF Checklist: https://resources.srhin.org/item/leef-checklist
- SRHIN lived-experience AI co-design guide: https://resources.srhin.org/item/ai-co-design-guide
- SRHIN GENSCORE and mental-health work: https://srhin.org/our-work/
- SRHIN GENCurate: https://srhin.org/alpha-center/

**Core proposition:** do not build another mental-health app. Test whether communities' own data-use rules can travel with data, govern downstream AI use, and be checked and challenged in practice.
