# Aidora evidence and Mozilla Fellowship readiness gaps

This document distinguishes what is evidenced by the repository and applicant confirmation from what remains a hypothesis or must be independently validated. It is designed to prevent overstating Aidora's traction or the new Fellowship proposal.

## 1. Aidora — verified engineering evidence

Repository: https://github.com/YousefAbaas/Aidora

The applicant confirms that he created and owns Aidora and is its principal developer and ongoing technical lead. The repository identifies his role in end-to-end technical design and implementation.

The project contains:
- Flutter/Dart mobile application using GetX.
- Django REST Framework backend and PostgreSQL persistence.
- REST/JSON client-server integration.
- Authentication and role-aware beneficiary, volunteer, and organisation workflows.
- Assistance requests, service discovery, volunteer tasks, and QR completion checks.
- Arabic and English user interfaces.
- Backend domains for accounts, organisations, and service requests.
- Unit, widget, integration, and Django test structures.
- Separate GitHub Actions workflows for Flutter and Django.
- Android build/signing and Firebase App Distribution automation.
- Docker/Docker Compose development setup.

Useful evidence:
- Project README: https://github.com/YousefAbaas/Aidora
- Architecture: https://github.com/YousefAbaas/Aidora/blob/mozilla-2027-prep/docs/architecture.md
- Backend documentation: https://github.com/YousefAbaas/Aidora/blob/mozilla-2027-prep/backend/README.md
- CI/CD notes: https://github.com/YousefAbaas/Aidora/blob/mozilla-2027-prep/docs/ci-cd.md
- Mozilla technical evidence dossier: AIDORA_TECHNICAL_EVIDENCE.md

Illustrative commits document architecture, API integration, PostgreSQL CI configuration, Firebase distribution automation, and removal/ignoring of production database dumps. Workflow definitions prove that automation is configured in the repository; the latest successful run must be checked separately before making a CI success claim.

## 2. Recent automated engineering verification

On 15 November 2026, the latest visible GitHub Actions runs on `main` both completed successfully:
- Django CI: https://github.com/YousefAbaas/Aidora/actions/runs/43721781747
- Flutter CI: https://github.com/YousefAbaas/Aidora/actions/runs/43721781742

The Django run completed its PostgreSQL-backed system checks and tests. The Flutter run completed analysis, unit/widget/integration test steps, signed Android build, Firebase App Distribution, artifact verification/upload, and signing-file cleanup. This supports the claim that the project has automated validation and a working QA release pipeline. It does not establish deployment to humanitarian organisations or use by beneficiaries.

## 3. Direct community feedback on Aidora — applicant-confirmed

The applicant has confirmed that, during Aidora's initial launch, he spoke directly with refugees and people who needed assistance and asked for their views on the application. The initial feedback was positive.

This should be described as **early, qualitative community feedback**. No participant count, dates, structured research protocol, written quotations, formal consent record, or measured outcome has been supplied so far.

Appropriate wording:
- “I sought direct feedback from refugees and people seeking assistance during Aidora's initial launch; the early responses were positive.”
- “Those conversations reinforced the importance of listening to intended users while building a service.”

Do not describe this as:
- a formal user study or representative survey;
- formal participatory co-design unless there is evidence of shared design decisions;
- a deployed humanitarian service or active-user base;
- measured improvement in access to aid or any other outcome;
- evidence of consultation with Nigerian mental-health communities.

If the applicant can later provide approximate dates, setting, number of conversations (only if known), the topics raised, and specific design changes made, this section can be strengthened without naming participants.

## 4. Ownership and licence

Aidora is identified as created and owned by Yousef Abbas, who led its end-to-end technical design and principal implementation. The repository's Apache License 2.0 notice identifies **Copyright 2026 Yousef Abbas**. Copyright ownership is compatible with Apache 2.0: the owner retains copyright while granting recipients the licence permissions, subject to the licence conditions.

Third-party packages, libraries, fonts, and externally sourced assets remain governed by their respective licences. Do not claim ownership of those materials.

## 5. What Aidora does and does not establish

It establishes a credible record of building a multi-layer software system and maintaining an engineering repository. It supports the applicant's ability to build an API, role-aware workflows, a database-backed application, tests, and a delivery pipeline.

It does not establish specialist expertise in clinical mental-health research, Nigerian health data governance, privacy law, or SRHIN's internal systems. The application should present the applicant as a capable software builder ready to learn from the host's clinical, ethics, technical, and community expertise.

## 6. SRHIN context discovered in public materials

An exploratory email asking SRHIN about fit, a possible remote Embedded Fellow arrangement, and a short introductory meeting was sent on 23 November 2026. No reply or endorsement is recorded yet. The message is documented in [HOST_OUTREACH_DRAFT.md](HOST_OUTREACH_DRAFT.md). The proposed technical gap remains unvalidated.

The 2027–2028 Mozilla RFP asks SRHIN to explore community-owned tools for governance, consent, privacy, and benefit-sharing around mental-health data used in AI, and to pilot with young people, people with lived experience, and community health workers.

SRHIN also publicly describes:
- GENSCORE and its work combining AI, lived experience, and local knowledge;
- GENCurate as a data capture/transcription/analysis platform;
- community-centred and lived-experience approaches;
- the LEEF pre-launch checklist for digital mental-health tools;
- a guide for people with lived experience to participate in AI mental-health tool design.

The project must build on these existing assets, including SRHIN's compensation/governance template, Epistemic Authority Decision Matrix, and co-production readiness tool. Its hypothesis is not that SRHIN lacks governance principles or policy templates. It is that a specific technical hand-off may remain between community decisions and downstream data access, reuse, AI development, audit, change/withdrawal, and benefit delivery. Only SRHIN and affected communities can validate this.

Relevant public resources:
- LEEF checklist: https://resources.srhin.org/item/leef-checklist
- Lived-experience AI co-design guide: https://resources.srhin.org/item/ai-co-design-guide
- Compensation and governance template: https://resources.srhin.org/item/lived-experience-compensation-governance-template
- Epistemic Authority Decision Matrix: https://resources.srhin.org/item/epistemic-authority-decision-matrix
- Co-production Readiness Self-Assessment: https://resources.srhin.org/item/coproduction-readiness-self-assessment
- SRHIN work: https://srhin.org/our-work/
- GENCurate: https://srhin.org/alpha-center/

## 7. Mozilla's six decision questions — candid assessment

| Mozilla question | Current evidence | Remaining gap / required action |
|---|---|---|
| Is it early? | The RFP defines a community-owned governance challenge; a possible technical response would connect SRHIN's existing community-governance instruments to downstream data-use and AI workflows. | Prove the gap is not already addressed by SRHIN's existing tools, agreements, or governance processes. |
| Who is it for? | RFP identifies young people, people with lived experience, and community health workers. | SRHIN and those communities must identify actual users, workflows, languages, and decision-makers. |
| Can you build it? | Aidora provides evidence of full-stack implementation, API/data architecture, tests, CI/CD, and release automation. | Prepare a demonstrable clean build, current CI run links, and a focused 12-month definition of done. |
| Who holds the power? | Applicant has experience asking intended users for feedback on Aidora. | That feedback is not Nigerian co-design. The Fellowship project must give affected communities real authority over rules, approvals, review, and evaluation. |
| What do you bring to / take from the cohort? | Applicant brings practical mobile/backend engineering and experience engaging intended users. | Articulate a specific contribution and learning agenda covering data governance, privacy engineering, community research, and public-interest technology. |
| Could you become a defining voice? | Aidora and the proposed open governance tool provide a credible foundation for an emerging public-interest software builder. | This requires a distinctive, shipped result, public documentation, peer exchange, and sustained community accountability—not a title claim. |

## 8. Mozilla's three investment questions

### Agency
Potential strength: individual permissions and community-level rules can be carried into operational workflows. SRHIN already has published tools for defining lived-experience authority and compensation; the gap, if any, is how these decisions are implemented and audited downstream.

Proof needed: evidence that participants understand their choices and that a community-designated body can approve/reject/condition proposed uses. The tool must not imply that an individual click alone resolves every ethical or legal issue.

### Commons
Potential strength: a reusable technical integration pattern could connect existing community-defined authority and compensation decisions to data-use workflows, if discovery proves that hand-off is currently missing.

Proof needed: a clean open-source release, interoperable documentation, maintenance plan, and evidence that the approach is not locked to one vendor. Sensitive data must remain private.

### Economic conditions
Potential strength: technically traceable follow-through on community-defined benefit and compensation commitments may improve accountability. SRHIN already publishes a compensation/governance template, so the unresolved question is implementation and accountability—not inventing another policy template.

Proof needed: the community itself must define benefits and the mechanism through which commitments are negotiated, monitored, and contested. A register alone does not change market power; the project must test whether it changes practice.

## 9. Critical submission gates

1. SRHIN confirms that a real, non-duplicative technical/operational gap remains after reviewing its existing governance resources and is willing to support the applicant's Embedded project.
2. Community groups and decision-making authority are defined by the host and affected people, not assumed by the applicant.
3. The applicant confirms the primary city/country where he will reside and work during the Fellowship, time-zone flexibility, legal ability to receive funds in that country, and a personal bank account that can receive U.S. funds.
4. The exact pilot, ethics approval, local data-protection/legal review, security review, and safeguarding arrangements are agreed before real mental-health data is used.
5. Aidora demo and current CI run status are verified.
6. The final application is written in the applicant's own ideas and voice. Mozilla allows AI for brainstorming, clarification, and translation, but warns against AI-generated complete responses.

## 10. Recommended order of work

1. SRHIN exploratory enquiry sent on 23 November 2026; await its response and pursue at most one polite follow-up after a reasonable interval.
2. Map SRHIN's LEEF, co-design guide, compensation/governance template, Epistemic Authority Decision Matrix, co-production readiness tool, GENSCORE, GENCurate, consent processes, data-use agreements, and governance.
3. Validate whether an integration/workflow that carries SRHIN-defined authority and obligations into an actual data-use/AI lifecycle solves a real gap; do not assume a new schema is needed.
4. An isolated synthetic policy-evaluation prototype and 17 unit tests have been added as an engineering probe, including malformed timestamp, invalid review flag, and unrecognised approval-status cases. GitHub Actions run #7 passed on 22 November 2026 (Python 3.12; run ID 45071331966). This verifies only the synthetic reference tests, not a host integration or production access-control system. Review its limitations and do not present it as host-validated or production-ready.
5. Resolve primary residence, funding/banking eligibility, and remote/time-zone feasibility before legal self-certification.
6. Only then prepare the applicant's own Letter of Intent responses.
