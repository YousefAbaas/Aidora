# Mozilla Foundation Fellowship 2027–2028 — Aidora preparation workspace

**Status:** preparation materials only. No Letter of Intent has been submitted, no host endorsement has been obtained, and no partnership is agreed.

## Recommended route under review

**Track I — Embedded Fellow; potential host: Slum & Rural Health Initiative (SRHIN), Nigeria.** The RFP's Track I package is $100,000 total ($75,000 stipend + $25,000 project budget), not the $125,000 Independent track package.

This is a provisional fit because the RFP specifically identifies SRHIN's challenge around community-owned governance, consent, privacy, and benefit-sharing for mental-health data used in AI. SRHIN also publicly describes existing community-engagement practices and resources. The proposed project must build on those assets, not duplicate them.

## The proposal in one sentence

Test whether a technical hand-off gap remains between SRHIN's existing community-governance instruments and downstream data/AI workflows. Reuse relevant open standards and build a narrow integration only if SRHIN and affected communities validate the need.

This is a hypothesis, not a confirmed unmet need. SRHIN's published compensation/governance template, Epistemic Authority Decision Matrix, and co-production readiness tool make duplication a real risk. Q1 is explicitly a discovery and validation phase; a no-build or pivot decision is acceptable.

## Start here

1. [Mozilla review matrix](MOZILLA_REVIEW_MATRIX.md) — the three investment questions, six selection questions, risks, evidence, and stop conditions.
2. [Project concept](PROJECT_CONCEPT.md) — problem hypothesis, host fit, intended users, scope, and 12-month outputs.
3. [Technical and ethical design](TECHNICAL_AND_ETHICAL_DESIGN.md) — standards mapping, governance workflow, possible adapter, safeguards, integration, testing, and release.
4. [Aidora technical evidence](AIDORA_TECHNICAL_EVIDENCE.md) — ownership, architecture, verifiable commits, CI/CD, successful workflow runs, and evidence boundaries.
5. [Evidence and gaps](EVIDENCE_AND_GAPS.md) — Aidora proof, early direct community feedback, candid fit assessment, and submission gates.
6. [Letter of Intent worksheet](APPLICATION_WORKSHEET.md) — official form fields, word limits, and answer-planning notes.
7. [SRHIN host enquiry record](HOST_OUTREACH_DRAFT.md) — sent on 22 November 2026; awaiting a response.
8. [Eligibility and host gates](ELIGIBILITY_AND_HOST_GATES.md) — Syria-resident funding/payment eligibility, host fit, duplication, and stop/go checks.
9. [Discovery and validation protocol](DISCOVERY_AND_VALIDATION_PROTOCOL.md) — host-led questions, evidence requirements, and build/adapt/no-build decision rules.
10. [Reference policy-check specification](REFERENCE_POLICY_CHECK_SPEC.md) — conservative decision semantics, security requirements, and synthetic acceptance cases.
11. [Synthetic policy-check prototype](../../prototypes/community-policy-check/README.md) — dependency-free reference implementation and unit tests; not a host integration.
12. [Synthetic policy API adapter](../../prototypes/community-policy-api/README.md) — isolated DRF wrapper and API tests; not mounted in Aidora or connected to a host.

## Current status — 25 November 2026

- **Mozilla eligibility:** the clarification email was sent on 22 November 2026 at 21:06 UTC. As of 25 November, the only reply is still the automated acknowledgement, which points applicants to the FAQ/RFP and gives the application deadline. It does **not** answer the Syria-residence, sanctions/compliance, own-name bank-account, payment-route, or remote-participation questions. There is also a wording point to clarify: the RFP calls attendance at the July 2027 kick-off and October 2027 MozFest mandatory, while the FAQ says in-person activities are not mandatory. Do not assume remote attendance satisfies the event requirement. Legal and payment eligibility remain unresolved.
- **Potential host:** the exploratory email to SRHIN was sent on 22 November 2026 at 21:06:48 UTC. No reply from SRHIN was found in Gmail as of 25 November. There is no host endorsement, partnership, access agreement, or community co-design.
- **Application:** no Letter of Intent has been submitted. The project concept remains conditional on legal eligibility, host interest, and validation of a non-duplicative need with affected communities.
- **Backend security:** PR #1 was merged into `main` as commit [05441b9](https://github.com/YousefAbaas/Aidora/commit/05441b9383a2f35e3703fa2c7492dcc2a81b3b77). The changes include authenticated role/ownership checks for QR completion, secure-by-default DRF permissions, stronger OTP/QR randomness, and uniform forgot-password responses. Django CI and Flutter CI both passed on the PR head.
- **Mobile / Android security:** PR #3 was merged into `main` as commit [490b53b](https://github.com/YousefAbaas/Aidora/commit/490b53ba2ca3737d2f077356dc7ba5601ccd15fb). Production cleartext traffic is disabled, development-only HTTP allowances are isolated to debug configuration, and token-bearing response bodies are no longer logged. Django CI and Flutter CI both passed on the PR head.
- **Synthetic policy API:** PR #9 was merged into `main` as commit [af98656](https://github.com/YousefAbaas/Aidora/commit/af986565c59c3791af0740f42e2635bda0109615). The API verifies Ed25519-signed synthetic approval evidence using configured public keys; the signing helper is separate from the API verifier. Synthetic API CI, Django CI, and Flutter CI all passed on the PR head.
- **Issuer-governance design:** PRs [#10](https://github.com/YousefAbaas/Aidora/pull/10) and [#11](https://github.com/YousefAbaas/Aidora/pull/11) remain open documentation-only proposals on separate branches. They add no migrations, runtime endpoints, or production trust registry. The schema is explicitly not migration-ready; do not implement it before the accountable host and affected communities resolve the governance questions.
- **Platform-backed mobile token storage:** [PR #13](https://github.com/YousefAbaas/Aidora/pull/13) remains open and unmerged. Its latest head (`52be870`) passed [Flutter CI run 126](https://github.com/YousefAbaas/Aidora/actions/runs/45557920006) and [Django CI run 109](https://github.com/YousefAbaas/Aidora/actions/runs/45557919689). This is a proposed migration to Android Keystore/iOS Keychain; do not claim it is already in `main`.
- **Additional backend security hardening:** [Draft PR #14](https://github.com/YousefAbaas/Aidora/pull/14) remains open and unmerged. Its latest head (`7d262fa`) passed [Django CI run 227](https://github.com/YousefAbaas/Aidora/actions/runs/45596575688) and [Flutter CI run 205](https://github.com/YousefAbaas/Aidora/actions/runs/45596575672). It proposes broader tenant isolation, verified-account enforcement, and OTP/PIN/task/QR authorization controls.
- **Residual security work:** the removed production database export remains in Git history; no history rewrite has been performed. Older signing-related strings have not been verified as placeholders or genuine credentials. Do not claim these matters are resolved.



## Current evidence

- The repository contains a synthetic policy-check core, its reference specification, and an isolated Django REST Framework adapter. These are experimental engineering probes only; they do not establish an SRHIN-validated need, production access control, valid consent, or GA4GH/ODRL conformance. The API's Ed25519 verifier is a technical improvement over the earlier synthetic fixture, but the configured issuer identity still does not prove a legitimate community mandate. The core policy evaluator remains a synthetic reference function, while the isolated API adapter now verifies Ed25519-signed synthetic approval evidence and uses server-side synthetic policy resolution. Its latest recorded API CI run passed. This is still a demonstration of a trust-boundary pattern, not proof of community authority, actual consent, a production policy registry, or standards conformance.

- Aidora was created and is owned by Yousef Abbas, who led its end-to-end technical design and principal implementation and continues to develop it.
- Aidora is an academic working software project; it has not been confirmed as a live humanitarian deployment.
- During Aidora's initial launch, the applicant spoke directly with refugees and people needing assistance; the initial feedback was positive. No participant count, formal study protocol, or measured outcome has been supplied. This is qualitative early feedback, not formal co-design or deployment evidence.
- In addition to the 15 November baseline runs listed above, successful pull-request CI has now been verified for the backend hardening (PR #1), Android/mobile hardening (PR #3), and Ed25519 approval-evidence changes (PR #9). The validated changes from all three PRs are merged into `main`; exact workflow links and commit references are recorded in [Aidora technical evidence](AIDORA_TECHNICAL_EVIDENCE.md).
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
6. The applicant's primary residence during the Fellowship, time-zone flexibility, legal ability to receive funding, and bank route must be stated accurately. The FAQ requires an own-name bank account able to accept U.S. funds and legal eligibility in the country of residence/work; Syria-specific eligibility remains unconfirmed and requires written clarification from Mozilla.
7. Mozilla allows AI for brainstorming, clarification, and translation. Final responses must express the applicant's own ideas and voice and must not be submitted as AI-generated text unchanged.

## Official and host references

- Mozilla 2027–2028 RFP: https://assets.mofoprod.net/network/documents/PUBLIC_2027_2028_Fellowship_RFP-3.pdf
- Mozilla 2027 call: https://www.mozillafoundation.org/en/what-we-do/grantmaking/fellowship/2027-call-for-applications/
- Mozilla 2027 FAQ: https://www.mozillafoundation.org/en/what-we-do/grantmaking/fellowship/2027-call-for-applications/faqs/
- SRHIN LEEF checklist: https://resources.srhin.org/item/leef-checklist
- SRHIN lived-experience AI co-design guide: https://resources.srhin.org/item/ai-co-design-guide
- SRHIN work: https://srhin.org/our-work/
- SRHIN GENCurate: https://srhin.org/alpha-center/
- SRHIN compensation/governance template: https://resources.srhin.org/item/lived-experience-compensation-governance-template
- SRHIN Epistemic Authority Decision Matrix: https://resources.srhin.org/item/epistemic-authority-decision-matrix
- SRHIN Co-Production Readiness Self-Assessment: https://resources.srhin.org/item/coproduction-readiness-self-assessment
- GA4GH DUO: https://www.ga4gh.org/product/data-use-ontology-duo/
- GA4GH Data Passports: https://www.ga4gh.org/product/data-passports/
- GA4GH Passports: https://www.ga4gh.org/product/passports/
- GA4GH Machine-Readable Consent Guidance: https://www.ga4gh.org/product/machine-readable-consent-guidance/
- W3C ODRL 2.2: https://www.w3.org/TR/odrl-model/

**Letter of Intent deadline:** 17 December 2026, 11:59 PM Pacific (UTC−8). The 12-month Fellowship begins 1 June 2027.
