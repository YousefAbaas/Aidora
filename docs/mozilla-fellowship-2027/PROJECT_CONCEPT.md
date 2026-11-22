# Project concept — Technical Bridge for Community-Governed Health-AI Data Use

**Working title:** Technical Bridge for Community-Governed Health-AI Data Use  
**Track under consideration:** Mozilla Foundation Track I — Embedded Fellow  
**Potential host:** Slum & Rural Health Initiative (SRHIN), Nigeria  
**Status:** A proposal for discussion only. It is not approved by SRHIN, not co-designed with Nigerian communities, and not a working product.

## 1. The opportunity — and the question to validate

Mozilla's 2027–2028 RFP identifies a challenge for SRHIN around community-owned governance, consent, privacy, and benefit-sharing for mental-health data used in AI. It calls for exploring community-owned tools and piloting with young people, people with lived experience, and community health workers.

This is not evidence that SRHIN lacks responsible practices. SRHIN publicly describes co-creation with people with lived experience and has already published the LEEF checklist, an AI mental-health co-design guide, a lived-experience compensation/governance template, an Epistemic Authority Decision Matrix, and a co-production readiness self-assessment. It also describes GENSCORE and GENCurate.

**The narrower hypothesis:** is there a missing technical hand-off between community decisions already made through SRHIN's governance processes and the downstream systems that handle data access, secondary use, AI development, audit, and benefit delivery? If so, can that hand-off be made traceable using existing standards and host-approved systems?

The first stage must map SRHIN's current systems, agreements, consent processes, technical controls, and community decision-making—including how its compensation/governance template and Epistemic Authority Decision Matrix are used in practice. If existing tools already meet the need, the project must adapt or stop. It must not build a duplicate product.

## 2. Novelty: build on standards, do not reinvent them

A preliminary landscape review identified existing work that must be reused and credited:

- **GA4GH Data Use Ontology (DUO):** standard terms for describing permitted data uses in a machine-readable form.
- **GA4GH Passports and Data Passports:** specifications and ongoing work for representing researcher permissions and data-level policy attributes.
- **GA4GH Machine-Readable Consent Guidance:** guidance for mapping consent language to DUO terms.
- **W3C ODRL 2.2:** a general policy expression model for permissions, prohibitions, constraints, and duties.

These are not interchangeable products, and their applicability to SRHIN's mental-health context must be assessed rather than assumed. In particular, the proposed work must not claim to invent machine-readable data-use conditions, policy passports, or access-control rules.

**The possible contribution is narrower and host-specific:** map how SRHIN's existing community-governance instruments connect to consent, data access, secondary use, AI development, audit, and benefit delivery. With SRHIN and affected communities, test whether a technical hand-off or accountability gap remains. Only if one is demonstrated should the project build an openly documented integration or workflow that operationalises—not replaces—existing community-defined authority and compensation processes.

The proposed project is therefore a **technical implementation and accountability bridge for existing community governance**, not a new universal data-use standard, consent app, or replacement policy framework. It must be an independently usable public-interest project co-defined with SRHIN, not simply staff augmentation or delivery of an existing SRHIN programme.

## 3. Fit with SRHIN's existing work

The proposal is intended to complement, not replace:
- **LEEF:** build on the lived-experience pre-launch checklist.
- **The lived-experience AI co-design guide, compensation/governance template, Epistemic Authority Decision Matrix, and co-production readiness tool:** treat these as existing host-authored foundations; do not reproduce them. Determine whether and how they are used in actual data/AI workflows.
- **GENSCORE:** do not build another screening model or diagnostic tool.
- **GENCurate:** do not rebuild patient-data capture, transcription, or analysis; investigate downstream governance only if discovery identifies a genuine gap.

Public descriptions are not a technical audit. Q1 must map existing practice and establish whether an additional technical layer is warranted.

## 4. Who it is for

Potential users, to be confirmed by SRHIN and affected communities:
- young people and adults with lived experience whose data may contribute to research or AI;
- community health workers and trusted facilitators;
- community-designated data stewards or governance representatives;
- research, data, and technical teams seeking to demonstrate compliance with agreed conditions.

Participation must be voluntary and accessible. Declining optional research or AI use must not reduce access to care. The project must not assume one representative speaks for an entire community.

## 5. Mozilla's three investment questions

### Agency — does it put people in control?

The goal is not to redesign SRHIN's existing authority framework. It is to test whether decisions already made through community-defined processes can be carried accurately into downstream technical workflows and remain understandable, revisable, and contestable. A digital interface alone is not agency; assisted and offline routes may be required.

### Commons — does it cultivate open infrastructure?

The project should reuse and contribute to open standards rather than create a proprietary schema. Any host-specific profile, mappings, reference code, tests, and non-confidential documentation should be openly published under licences agreed with Mozilla and SRHIN. Sensitive health data and identifiable records must never be made public.

### Economic conditions — can it change how markets work?

SRHIN already publishes a lived-experience compensation/governance template. The project should not create a competing benefit-sharing policy or generic register. It should test whether existing community-defined commitments can be referenced and their fulfilment status made visible in one downstream workflow. Benefits remain community-defined; software cannot guarantee fair bargaining, payment, or enforcement.

## 6. What may be built — only after validation

A deliberately small, standards-aligned technical scope may include:
1. **Standards mapping:** map SRHIN's current data-use terms and governance requirements to DUO, GA4GH Data Passports, ODRL, or other relevant standards where appropriate.
2. **Decision hand-off mapping:** map how decisions already made under SRHIN's authority and governance processes are represented in downstream systems; do not recreate the authority framework.
3. **Interoperability adapter:** translate validated host-approved conditions into existing machine-readable representations where technically and semantically appropriate.
4. **Policy-check integration:** demonstrate one narrow, approved workflow that checks a proposed use and returns allow, deny, or human/community review.
5. **Commitment traceability:** if the host validates a gap, link to existing community-defined compensation/benefit commitments and expose only the minimum approved status, owner, and evidence needed for accountability. Do not replace the host's policy template or imply software enforces external contracts.
6. **Accessible explanation:** provide a plain-language view of what is proposed, who decides, and how to raise a concern, with low-bandwidth and assisted alternatives.

No new standard should be created if an existing one can represent the requirement. Where no suitable representation exists, document the gap and seek community and standards-community input before proposing an extension.

## 7. A realistic 12-month pathway

**Q1 — Discover and decide (June–August 2027).** Map SRHIN systems, policies, LEEF/co-design processes, compensation/governance tools, consent, data flows, governance, benefit expectations, and relevant standards. Conduct host-approved, compensated discovery with the groups SRHIN identifies. Deliver a jointly validated gap analysis and a build / adapt / no-build decision.

**Q2 — Specify and prototype (September–November 2027).** If a gap is validated, define the smallest community governance workflow and standards mapping. Build an alpha using synthetic data, with tests for policy interpretation and human-review paths.

**Q3 — Integrate and evaluate (December 2027–February 2028).** If approved, implement one staging adapter or controlled import/export pattern. Test accessibility, security, auditability, standards conformance, and operational burden.

**Q4 — Governed pilot and open release (March–May 2028).** Run a pilot only after host, community, ethics, legal, privacy, safeguarding, and security approvals. Evaluate participant understanding, decision traceability, appeal/change handling, and benefit-commitment tracking. Publish reusable code, mappings, documentation, and a community-reviewed report without sensitive data.

## 8. How success will be measured

Baselines and targets must be set with SRHIN and community participants in Q1. Candidate measures:
- whether participants understand the proposed data use and know how to question or change their choices;
- whether out-of-scope requests are blocked or escalated before access;
- whether decisions can be reconstructed, including authority, conditions, and applicable policy version;
- whether community representatives consider the review and appeal process legitimate;
- whether benefit commitments have named owners, due dates, evidence, and a process for contesting non-delivery;
- whether the standards mapping is interoperable and avoids unnecessary new vocabulary;
- whether the workflow adds acceptable burden for participants and staff.

Do not invent numeric targets or impact claims before discovery and approval.

## 9. Why the applicant can contribute

The applicant created and owns Aidora and led its end-to-end technical design and principal implementation: Flutter/Dart, Django REST Framework, PostgreSQL, APIs, authentication, role-aware workflows, testing, and GitHub Actions automation. This demonstrates transferable software-building ability for an API, workflow, and integration prototype.

The applicant does not claim specialist mental-health research expertise, Nigerian community-governance expertise, or prior knowledge of SRHIN's internal systems. The work must be shaped with SRHIN's technical, clinical, ethics, and community expertise.

During Aidora's initial launch, the applicant spoke directly with refugees and people seeking assistance and received positive early feedback. This is qualitative early learning, not formal co-design, a measured user base, or evidence of impact in Nigeria.

## 10. Conditions that must be satisfied

- SRHIN confirms a specific unmet technical/operational need after reviewing existing governance tools, workflows, and standards.
- The host and applicant agree on an independent project scope rather than staff augmentation or delivery of existing programme services.
- SRHIN is willing to consider the applicant as an Embedded Fellow and support community-led discovery.
- Affected communities define their decision-making role, compensation, accessibility, and safeguarding arrangements.
- The proposed work is demonstrably additive to DUO, GA4GH Data Passports, ODRL, and SRHIN's existing work.
- Ethics, legal, data-protection, privacy, security, and safeguarding approvals precede any real-data pilot.
- Synthetic data is the default during development.
- The applicant's Fellowship-period location, time-zone flexibility, legal eligibility to receive funds, and bank transfer route meet Mozilla requirements.
- There is a credible maintenance and governance pathway after the Fellowship.

## 11. Preliminary standards and host references

- GA4GH Data Use Ontology (DUO): https://www.ga4gh.org/product/data-use-ontology-duo/
- GA4GH Passports: https://www.ga4gh.org/product/passports/
- GA4GH Data Passports: https://www.ga4gh.org/product/data-passports/
- GA4GH Machine-Readable Consent Guidance: https://www.ga4gh.org/product/machine-readable-consent-guidance/
- W3C ODRL 2.2 Recommendation: https://www.w3.org/TR/odrl-model/
- Mozilla 2027–2028 Fellowship RFP: https://assets.mofoprod.net/network/documents/PUBLIC_2027_2028_Fellowship_RFP-3.pdf
- SRHIN LEEF Checklist: https://resources.srhin.org/item/leef-checklist
- SRHIN lived-experience AI co-design guide: https://resources.srhin.org/item/ai-co-design-guide
- SRHIN work: https://srhin.org/our-work/
- SRHIN GENCurate: https://srhin.org/alpha-center/

**Core proposition:** do not invent another consent app or data-use standard. Test whether existing open standards can be made meaningfully accountable to community-defined decision rights and benefit commitments in SRHIN's real workflows.
