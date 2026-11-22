# Aidora evidence and Fellowship readiness gaps

This document distinguishes repository evidence from claims that still need confirmation. It is intended to prevent accidental overstatement in the Mozilla application.

## 1. Evidence visible in the repository

Repository: https://github.com/YousefAbaas/Aidora

The public README currently describes Aidora as a fourth-year Informatics Engineering academic project for coordinating humanitarian assistance between displaced communities, organisations, and volunteers.

The README and documentation describe:
- Flutter/Dart mobile application using GetX.
- Django REST Framework backend and PostgreSQL persistence.
- REST/JSON client-server integration.
- Authentication and role-aware beneficiary, volunteer, and organisation workflows.
- Assistance requests, service discovery, volunteer tasks, and QR completion checks.
- Arabic and English user interfaces.
- Backend domains for accounts, organisations, and service requests.
- Unit, widget, and integration test structure.
- GitHub Actions workflows and Docker development setup.

The project README and architecture documentation identify Yousef Abbas as the creator, owner, principal developer, and lead for the end-to-end technical design and implementation. The applicant has directly confirmed that Aidora is his project and that he is its primary ongoing developer.

Useful links:
- Project README: https://github.com/YousefAbaas/Aidora
- Architecture: https://github.com/YousefAbaas/Aidora/blob/main/docs/architecture.md
- Backend README: https://github.com/YousefAbaas/Aidora/blob/main/backend/README.md
- Engineering decisions: https://github.com/YousefAbaas/Aidora/blob/main/docs/engineering-decisions.md
- Test suite description: https://github.com/YousefAbaas/Aidora/blob/main/test/README.md

## 2. Confirmed limitations from the applicant's current answers

| Topic | Current known position | How to describe it honestly |
|---|---|---|
| Actual use | Academic only; no external real-world deployment confirmed | “Academic project / working prototype”, not “deployed humanitarian platform”. |
| Community input | Some engagement or discussion occurred | Record who, when, what they said, and which design choices changed. Do not call it formal co-design unless that is accurate. |
| Code ownership | Applicant confirms that he created and owns Aidora and is its principal developer | State clearly that he is the project creator and owner. Attribute third-party libraries and assets under their own licences. |
| SRHIN relationship | None established in this preparation work | Do not imply SRHIN endorsement, partnership, access, or approval. |
| New governance project | Concept only | Select “Concept or wireframe only” unless a separate prototype is actually built. |
| Mental-health research | No established direct experience evidenced here | Be candid; explain relevant transferable engineering skills and willingness to learn from the host. |

## 3. Technical claims that need evidence before submission

- Demonstrate that the public repository builds and tests from a clean checkout.
- Capture a short demo or screen recording of real Aidora workflows, with test accounts and no real beneficiary data.
- Provide a simple architecture diagram and explain what the applicant personally implemented.
- Distinguish code that is complete from functionality documented but not independently verified.
- Verify current CI status in GitHub Actions; the presence of a workflow file alone does not prove a successful current run.
- Avoid describing the production security configuration as independently audited. Backend documentation describes security controls, but a repository review is not a penetration test or compliance audit.
- Remove or rotate any credential, token, signing material, private URL, or personal data if one is ever found in source control. No such disclosure is alleged by this note.

## 4. Project ownership and open-source licensing

The applicant has confirmed that Aidora is his project: he created it, owns it, leads its ongoing development, and is its principal technical contributor. The root README and architecture documentation describe his end-to-end role across the Flutter client, Django backend, database and API design, integration, testing, and delivery automation.

The repository's Apache License 2.0 notice now identifies **Copyright 2026 Yousef Abbas**. The backend README and project README use consistent authorship and licensing language. Copyright ownership and an open-source licence are compatible: the creator retains copyright while granting users the permissions stated in Apache 2.0, subject to its conditions.

Third-party dependencies and externally sourced assets remain under their respective licences. The application should not claim ownership of those separate materials. The prior backend wording that described the backend as proprietary has been removed because it contradicted the repository-wide Apache 2.0 notice.

## 5. Community evidence to assemble

For every discussion or feedback activity the applicant mentioned, record privately:
- Approximate date and setting.
- Participant group (avoid names and unnecessary personal data).
- Number of participants, only if known.
- How participants were invited and whether participation was voluntary.
- The questions or topics discussed.
- Key themes in participants' own terms.
- What changed in Aidora as a result.
- What did not change and why.
- Whether notes, consent, or supervisor confirmation exist.

Do not reconstruct or invent participant quotes, counts, or outcomes. If there are no written records, describe the discussion as informal and limited.

## 6. SRHIN-specific evidence to obtain

Public information reviewed for this preparation:
- SRHIN describes work in mental health, digital health/AI/data science, community organising, research, and lived experience.
- SRHIN describes GENSCORE as an initiative bringing together AI, lived experience, and local knowledge for culturally grounded screening.
- SRHIN describes GENCurate as a data platform for capturing, transcribing, and analysing patient data.
- The Mozilla RFP separately identifies a community-governance, consent, privacy, and benefit-sharing challenge for SRHIN.

What is not known:
- Whether SRHIN has already implemented consent, data-use governance, withdrawal, audit, and benefit-sharing controls.
- Whether SRHIN would consider the applicant for a remote Embedded role.
- Whether it has an integration point or technical preference for a governance layer.
- Which communities would want to participate and on what terms.
- Whether the host expects a particular language, clinical background, or Nigeria-based experience beyond the published preferences.

The first conversation should validate these matters before any technical assumptions are treated as requirements.

## 7. Applicant eligibility and practical feasibility

Resolve before answering “Yes” to Mozilla's legal eligibility question:
- Primary city and country of residence during the Fellowship (June 2027 onward).
- Whether the applicant can legally receive a grant/stipend from Mozilla in that country.
- Whether an account in the applicant's own name can receive USD payments from the U.S.-based funder.
- Whether any applicable sanctions, banking restrictions, local rules, or transfer screening affect the proposed route.
- Tax and reporting obligations in the place of residence/work.

For Embedded Track I:
- Confirm the applicant can work flexibly with the host's WAT (UTC+1) schedule.
- The RFP identifies Nigeria as SRHIN's location preference; being remote from elsewhere is not an automatic guarantee of host preference.
- Confirm availability for the full 12-month project and cohort participation.

## 8. Immediate priority order

1. Contact SRHIN to ask whether it would consider a remote applicant and to validate the project gap.
2. Resolve grant/banking eligibility with Mozilla and the receiving bank before the legal self-certification.
3. Document the actual community feedback already received for Aidora.
4. Resolve contributor and university rights before making a public licensing claim.
5. Prepare an honest Aidora demo and technical evidence package.
6. Only then turn the concept into the applicant's own Letter of Intent answers.
