# Mozilla Fellowship fit review — Track I / SRHIN

**Purpose:** internal red-team review against Mozilla's published 2027–2028 RFP. This is not an official score or an acceptance prediction.

## Executive assessment

The strongest defensible case is a **rising technical builder with an inspectable full-stack project (Aidora), early direct qualitative feedback from intended users, and a narrowly scoped proposal to connect SRHIN's existing community-governance decisions to downstream data/AI workflows—if a real technical gap is confirmed**.

The main risks are not coding ability. They are:
1. whether SRHIN confirms a specific, non-duplicative need after its existing community-engagement resources and systems are mapped;
2. whether affected communities hold real decision-making power in the project, rather than simply testing a developer-designed tool;
3. whether a credible benefit-sharing mechanism can be designed with the community and shown to affect practice;
4. whether the applicant's Fellowship-period residence and banking route meet Mozilla's funding requirements;
5. whether SRHIN is willing to consider a remote Embedded Fellow from the applicant's location and schedule.

**Do not call the application “10/10” until these gates are resolved.** The target is a complete, evidence-backed application with no avoidable weaknesses—not a fabricated guarantee of selection.

## A. Novelty and standards landscape

The initial novelty check identified existing work that must be reused and credited: GA4GH DUO describes permitted data uses; GA4GH Passports and Data Passports address researcher permissions and data-level policy attributes; GA4GH Machine-Readable Consent Guidance maps consent language to DUO; W3C ODRL 2.2 expresses permissions, prohibitions, constraints, and duties. The proposal must not claim to invent a new data-use ontology, passport, or policy language.

The only defensible potential contribution is a host- and community-validated technical hand-off or integration that carries decisions already made through SRHIN's existing authority and compensation processes into one downstream data/AI workflow. If SRHIN's current processes and systems already do this adequately, do not build a new tool.

## B. The three questions Mozilla asks of every investment

### 1. Agency — does it put people in control?

**What the proposal offers**
- Separate individual preferences and collective/community governance rules.
- Purpose-specific conditions rather than blanket permission.
- Plain-language access to current choices and a route to request changes.
- Faithfully carry community-designated decisions—made through existing approved processes—into downstream requests without weakening or reinterpreting them.
- A traceable reference to what was decided, by whom, under which applicable policy/agreement version, and why—only to the extent approved by the host and community.

**What reviewers may challenge**
- A consent screen is not meaningful control by itself.
- A digital workflow could exclude people without smartphones, connectivity, literacy, or confidence.
- The person controlling the data system may remain more powerful than the person whose data is used.
- Withdrawal cannot automatically erase every copy or remove information already learned by a model.

**What makes the case credible**
- Community representatives define governance and decision rights.
- Refusal of optional research/AI use does not affect access to care.
- Accessible assisted/offline routes exist.
- The project explains limits of technical enforcement and withdrawal honestly.
- Q1 defines community decision rights before the prototype is built.

**Status:** strong design direction; not yet demonstrated in the proposed Nigerian context. Requires host and community validation.

### 2. Commons — does it cultivate open infrastructure?

**What the proposal offers**
- An open, standards-aligned mapping or adapter only where existing standards do not cover a validated host/community need.
- A documented policy-check API and reference implementation.
- Reusable tests, governance workflow templates, deployment instructions, and implementation guidance.
- A design that independent organisations can adopt without buying a proprietary product.

**What reviewers may challenge**
- A one-host dashboard may not be a commons.
- A policy representation cannot enforce terms in systems that do not check it.
- Open-sourcing sensitive information would create harm.

**What makes the case credible**
- Reuse and contribute to DUO, GA4GH Passports/Data Passports, and ODRL where appropriate; publish only validated mappings, adapters, tests, and governance workflow documentation.
- Demonstrate a clean, documented integration pattern where approved.
- Keep health records and personal data private; openness applies to code, validated mappings, methods, and non-confidential learning.
- Include self-hosting and maintenance documentation.

**Status:** promising and technically feasible; portability and independent reuse must be demonstrated.

### 3. Economic conditions — can it change how markets work?

**What the proposal offers**
- Community-defined data-use conditions for data-access and AI-use requests.
- A minimal link to existing community-defined compensation/benefit commitments and approved delivery-status evidence, not a replacement policy or generic register.
- Greater transparency when researchers or organisations request secondary use.
- Potential leverage for communities to negotiate conditions before data is reused.

**What reviewers may challenge**
- An audit register alone does not redistribute value or change market power.
- Benefit-sharing can become symbolic unless communities decide what counts and can contest failure.
- The tool cannot guarantee payment or fair outcomes without agreements, governance, and enforcement outside the software.

**What makes the case credible**
- The community—not the developer—defines acceptable benefits and the decision process.
- Commitments are recorded as part of approval decisions.
- The pilot tests whether the process changes review, negotiation, transparency, or fulfilment.
- Benefits may be financial or non-financial and are not predetermined.

**Status:** currently the least evidenced dimension. It requires substantive community design, not merely a database feature.

## C. Mozilla's six selection questions

| RFP question | Current case | Evidence / action needed |
|---|---|---|
| **1. Is it early?** | The RFP defines a community-owned governance challenge; a standards-aligned community governance workflow may be a focused response, if discovery proves a gap. | Map SRHIN's LEEF, co-design, compensation/governance template, Epistemic Authority Decision Matrix, co-production readiness tool, consent, agreements, platform controls, and relevant standards. If the gap is solved, do not build. |
| **2. Who is it for?** | Potential users: young people and people with lived experience, community health workers/facilitators, community data stewards, and research/technical teams. | SRHIN and affected communities must identify actual users, languages, contexts, and decision-makers. |
| **3. Can you build it?** | Aidora demonstrates full-stack implementation across Flutter, Django REST Framework, PostgreSQL, APIs, authentication, role-aware workflows, tests, CI/CD, and Android release automation. | Prepare a clean build/demo and verify current workflow runs. Keep the plan focused on one validated governance workflow, one standards mapping/adapter, and one approved integration path. |
| **4. Who holds the power?** | The applicant has experience listening directly to refugees and people seeking assistance during Aidora's initial launch; early feedback was positive. | That is not Nigerian co-design. Give affected communities real authority to define terms, governance, review, and evaluation before implementation. |
| **5. What do you bring to / take from the cohort?** | Bring full-stack engineering, product integration, automation, and an emerging public-interest technology perspective. | Explain the learning agenda: privacy engineering, data governance, participatory research, health-AI oversight, and sustainable open infrastructure. Be ready to share technical methods. |
| **6. Could you become a defining voice?** | There is a plausible trajectory from Aidora to open, community-governed data infrastructure. | Do not claim current field leadership. Show how a shipped, openly documented project, community accountability, public writing, and peer collaboration could establish this role. |

## D. Applicant evidence — strengths and limits

### Strong, inspectable evidence
- Aidora is identified by the applicant as his created and owned project; he is its principal developer and ongoing technical lead.
- It is a multi-layer software project, not merely a slide deck or isolated code exercise.
- GitHub history documents architecture, Flutter/API integration, PostgreSQL CI configuration, GitHub Actions automation, signed Android distribution, and repository hygiene.
- It provides relevant experience building a platform intended to support people seeking assistance.

### Early community learning
The applicant says he spoke directly with refugees and people needing assistance during Aidora's initial launch and received positive initial feedback. This is useful qualitative evidence of listening to intended users.

It is not evidence of a formal or representative user study, formal co-design, a measured user base, live NGO deployment, or demonstrated outcomes. No participant count, date, written quotation, or specific design change has been supplied. Do not invent them.

### Limits to acknowledge
The applicant is not claiming clinical mental-health research expertise, specialist Nigerian community knowledge, or prior experience with SRHIN's internal systems. The strongest case is as a software builder ready to learn from SRHIN's technical, clinical, ethics, and community expertise.

## E. Host fit — SRHIN

The RFP describes SRHIN's challenge as community-owned governance, consent, privacy, and benefit-sharing for mental-health data used in AI, with piloting among young people, people with lived experience, and community health workers.

SRHIN's public materials show existing work on GENSCORE, GENCurate, the LEEF pre-launch checklist, and a guide for people with lived experience to participate in AI mental-health tool design.

The proposal must be more precise than “build a consent app” or another governance template. SRHIN already publishes tools that address co-production readiness, lived-experience decision authority, and compensation/governance. The only plausible differentiator is a technical bridge from those existing decisions into downstream data/AI workflows, with reviewable traceability. This remains a hypothesis until SRHIN confirms a real workflow gap.

## F. Scope test — can it be delivered in 12 months?

**Definition of done**
1. A community-validated problem statement and workflow map.
2. A validated community-governance workflow and standards mapping or adapter, with plain-language explanations.
3. A tested policy-check API returning allow / deny / review with traceable reasons.
4. A minimal governance-review and benefit-commitment workflow.
5. One host-approved staging integration or documented import/export pattern.
6. A threat model, privacy review, accessibility/usability findings, and clear limitations.
7. A governed pilot only if all approvals are complete.
8. An open-source release with tests, self-hosting guide, API documentation, and maintenance plan.

**Stop/pivot conditions**
- Existing SRHIN systems already meet the need.
- The affected community does not want the tool or rejects the proposed governance model.
- No appropriate community governance authority can be established.
- Legal, ethics, safeguarding, or security approvals cannot be obtained.
- The tool would require copying sensitive records into a new central database.
- The host cannot support or supervise the proposed project.

A no-build or pivot decision in Q1 is evidence of rigour, not failure.

## G. Risk register

| Risk | Severity | Mitigation |
|---|---|---|
| Duplicate of existing SRHIN systems/resources | High | Discovery and technical mapping before design commitments |
| Token community participation | High | Community-defined decision rights, compensation, review, and appeal |
| Consent mistaken for legal/ethical permission | High | Separate individual choice, community governance, ethics review, and legal basis |
| Policy representation ignored by external systems | High | Integrations, agreements, monitoring, explicit technical limits |
| Harm from storing sensitive mental-health data | Critical | No raw records in governance service; synthetic data by default |
| Benefit-sharing remains symbolic | High | Community-defined commitments with owners, dates, evidence, and dispute process |
| Scope too broad for 12 months | Medium | One validated governance workflow, one standards mapping/adapter, one approved integration path |
| Host/time-zone/location/funding eligibility | Critical | Host response and funding/banking confirmation before legal self-certification |
| Applicant claims exceed evidence | High | Evidence ledger; no invented numbers, deployment, impact, or partnership |

## H. Readiness conclusion

The proposal has a credible technical foundation and a more precise fit to the RFP than simply expanding Aidora. Aidora is evidence of the applicant's ability to build; it is not itself the proposed Mozilla project.

**It is not yet honest to represent the proposal as a fully validated 10/10 fit.** It becomes substantially stronger only after:
1. SRHIN confirms the unmet need and interest in the applicant;
2. affected communities shape and govern the project;
3. the benefit-sharing mechanism is real rather than decorative;
4. location, remote/time-zone, legal funding, and bank eligibility are resolved;
5. an Aidora demo and current CI evidence are checked.

The target is a complete, technically credible, community-governed application—not an inflated score or guaranteed selection.
