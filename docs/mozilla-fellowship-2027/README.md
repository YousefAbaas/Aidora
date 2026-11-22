# Mozilla Foundation Fellowship 2027–2028 — Aidora preparation workspace

**Status:** preparation materials only. No Letter of Intent has been submitted, no host endorsement has been obtained, and no partnership is agreed.

## Recommended route under review

**Track I — Embedded Fellow; potential host: Slum & Rural Health Initiative (SRHIN), Nigeria.**

This is a provisional fit because the RFP specifically identifies SRHIN's challenge around community-owned governance, consent, privacy, and benefit-sharing for mental-health data used in AI. SRHIN also publicly describes existing community-engagement practices and resources. The proposed project must build on those assets, not duplicate them.

## The proposal in one sentence

Explore whether existing open standards—GA4GH DUO, GA4GH Passports/Data Passports, and W3C ODRL—can be applied to community-defined decision rights and benefit commitments in SRHIN's health-AI data workflows, with a small adapter or governance workflow only if a validated gap remains.

This is a hypothesis, not a confirmed unmet need. Q1 is explicitly a discovery and validation phase. A no-build or pivot decision is acceptable if SRHIN and affected communities find the gap is already addressed.

## Start here

1. [Mozilla review matrix](MOZILLA_REVIEW_MATRIX.md) — the three investment questions, six selection questions, risks, evidence, and stop conditions.
2. [Project concept](PROJECT_CONCEPT.md) — problem hypothesis, host fit, intended users, scope, and 12-month outputs.
3. [Technical and ethical design](TECHNICAL_AND_ETHICAL_DESIGN.md) — standards mapping, governance workflow, possible adapter, safeguards, integration, testing, and release.
4. [Aidora technical evidence](AIDORA_TECHNICAL_EVIDENCE.md) — ownership, architecture, verifiable commits, CI/CD, successful workflow runs, and evidence boundaries.
5. [Evidence and gaps](EVIDENCE_AND_GAPS.md) — Aidora proof, early direct community feedback, candid fit assessment, and submission gates.
6. [Letter of Intent worksheet](APPLICATION_WORKSHEET.md) — official form fields, word limits, and answer-planning notes.
7. [SRHIN host enquiry draft](HOST_OUTREACH_DRAFT.md) — unsent message for the applicant to review and send personally.

## Current evidence

- Aidora was created and is owned by Yousef Abbas, who led its end-to-end technical design and principal implementation and continues to develop it.
- Aidora is an academic working software project; it has not been confirmed as a live humanitarian deployment.
- During Aidora's initial launch, the applicant spoke directly with refugees and people needing assistance; the initial feedback was positive. No participant count, formal study protocol, or measured outcome has been supplied. This is qualitative early feedback, not formal co-design or deployment evidence.
- The latest visible GitHub Actions runs on `main`, dated 15 November 2026, passed both Django CI and Flutter CI. The Flutter run also completed signed Android release distribution to Firebase App Distribution.
- The applicant's experience is transferable software engineering, not specialist mental-health or Nigerian data-governance expertise.
- SRHIN's public materials include GENSCORE, GENCurate, the LEEF checklist, a lived-experience AI co-design guide, a compensation/governance template, an Epistemic Authority Decision Matrix, and a co-production readiness self-assessment. These existing assets make duplication a serious risk. The proposal must test whether a narrow technical integration gap remains, rather than create another governance policy or participation framework.
- A preliminary novelty review identified GA4GH DUO, GA4GH Passports/Data Passports, GA4GH Machine-Readable Consent Guidance, and W3C ODRL as relevant existing work. The proposal is reframed to build on them, not claim to invent a new data-use passport or ontology.
- The potential Fellowship project is a concept. No SRHIN partnership, endorsement, access, or community co-design in Nigeria is claimed.

## Accuracy and ethics rules

1. Distinguish implemented engineering from planned features.
2. Describe Aidora's launch feedback as qualitative initial feedback, not user traction, formal co-design, or demonstrated impact.
3. Do not imply that SRHIN has endorsed the applicant or that its existing systems lack safeguards.
4. Do not collect or process real mental-health data before host, community, ethics, legal, privacy, safeguarding, and security approval.
5. Open software and documentation do not mean publishing sensitive or identifiable data.
6. The applicant's primary residence during the Fellowship, time-zone flexibility, legal ability to receive funding, and bank route must be stated accurately.
7. Mozilla allows AI for brainstorming, clarification, and translation. Final responses must express the applicant's own ideas and voice and must not be submitted as AI-generated text unchanged.

## Official and host references

- Mozilla 2027–2028 RFP: https://assets.mofoprod.net/network/documents/PUBLIC_2027_2028_Fellowship_RFP-3.pdf
- Mozilla 2027 call: https://www.mozillafoundation.org/en/what-we-do/grantmaking/fellowship/2027-call-for-applications/
- Mozilla 2027 FAQ: https://www.mozillafoundation.org/en/what-we-do/grantmaking/fellowship/2027-call-for-applications/faqs/
- SRHIN LEEF checklist: https://resources.srhin.org/item/leef-checklist
- SRHIN lived-experience AI co-design guide: https://resources.srhin.org/item/ai-co-design-guide
- SRHIN work: https://srhin.org/our-work/
- SRHIN GENCurate: https://srhin.org/alpha-center/
- GA4GH DUO: https://www.ga4gh.org/product/data-use-ontology-duo/
- GA4GH Data Passports: https://www.ga4gh.org/product/data-passports/
- GA4GH Passports: https://www.ga4gh.org/product/passports/
- GA4GH Machine-Readable Consent Guidance: https://www.ga4gh.org/product/machine-readable-consent-guidance/
- W3C ODRL 2.2: https://www.w3.org/TR/odrl-model/

**Letter of Intent deadline:** 17 December 2026, 11:59 PM Pacific (UTC−8). The 12-month Fellowship begins 1 June 2027.
