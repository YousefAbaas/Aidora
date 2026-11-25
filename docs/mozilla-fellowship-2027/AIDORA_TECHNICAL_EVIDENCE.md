# Aidora — Technical Evidence for Mozilla Fellowship

**Project creator and owner:** Yousef Abbas  
**Role:** Principal developer, technical lead, and ongoing maintainer  
**Project context:** Individual-led academic software engineering project; working software prototype, not a live humanitarian service.

This document maps concrete repository evidence to the applicant's technical contribution. It distinguishes implemented engineering work from unverified deployment or impact claims.

## 1. Project authorship and scope

I created Aidora and own the project. I led its end-to-end technical design and principal implementation, covering the Flutter mobile application, Django REST Framework backend, PostgreSQL data layer, API integration, authentication and role-aware workflows, testing, and delivery automation.

Aidora addresses coordination of humanitarian assistance between people requesting support, organisations, and volunteers. It includes Arabic and English user interfaces and workflows for service discovery, assistance requests, organisation review, volunteer tasks, and QR-based completion.

Aidora was developed in an academic context. It has not been confirmed as a live service used by humanitarian organisations or beneficiaries; it should therefore be presented as a working engineering project and prototype, not as evidence of field deployment or measured humanitarian impact.

## 2. Technical architecture

| Layer | Implemented technology / responsibility |
|---|---|
| Mobile application | Flutter and Dart; GetX state management; screens, controllers, models, and service layers |
| Backend | Python, Django, Django REST Framework |
| API boundary | REST/JSON endpoints connecting the mobile client and backend |
| Data persistence | PostgreSQL through Django ORM |
| Authentication | JWT access/refresh-token workflows; account verification and password-recovery flows |
| Authorisation | Role-aware beneficiary, volunteer, and organisation workflows enforced by backend endpoints |
| Delivery | Docker/Docker Compose development setup; GitHub Actions workflows |
| Mobile release automation | Android release build, signing from GitHub Secrets, GitHub OIDC / Google Workload Identity Federation, Firebase App Distribution, and workflow artifact upload |
| Quality checks | Flutter static analysis and unit/widget/integration test commands; Django system checks and backend tests against PostgreSQL |

See [system architecture](../architecture.md), [backend documentation](../../backend/README.md), [API integration guide](../../API_INTEGRATION_GUIDE.md), and [CI/CD notes](../ci-cd.md).

## 3. Verifiable GitHub engineering history

Examples of commits authored under the applicant's GitHub account:

- [Document system architecture and end-to-end technical ownership](https://github.com/YousefAbaas/Aidora/commit/47be8158117fb0cc8a295b1f2d2bc3bcbfbbe6f7) — architecture boundaries, ownership description, and technical responsibilities.
- [Correct API integration guide to match current token storage and client layers](https://github.com/YousefAbaas/Aidora/commit/6c3f78a72edfca1def6734cdb9ddb30bd8313bc3) — client/backend API integration and authentication documentation.
- [Configure Flutter API base URLs](https://github.com/YousefAbaas/Aidora/commit/5698ed26f08860ce127050607db413249d08ec7b) — environment endpoint configuration.
- [Automate signed Android APK distribution](https://github.com/YousefAbaas/Aidora/commit/923f9468b8399da9d9865226102580e964322ae2) — Android release/distribution pipeline work.
- [Provide PostgreSQL DATABASE_URL for Django tests](https://github.com/YousefAbaas/Aidora/commit/36ddaf74693fb91e21a87ea2cec2366e4b0feb4a) — backend CI database configuration.
- [Remove a production database dump from the public repository](https://github.com/YousefAbaas/Aidora/commit/4a87c33c8fd9a12f6790c73183b24b9928760962) — repository hygiene and protection of database exports.
- [Ignore production database exports and backup files](https://github.com/YousefAbaas/Aidora/commit/3db0f709d8d6b923343be961fa0810dbffaa9ea5) — prevent accidental reintroduction of database backup files.

These are illustrative links to specific engineering changes, not a claim that commit count alone measures project quality.

## 4. CI/CD evidence in the repository

Two separate GitHub Actions workflows are present in the repository.

### Flutter / Android workflow

File: [`.github/workflows/flutter-ci.yml`](../../.github/workflows/flutter-ci.yml)

The workflow configuration:

1. Runs on pushes and pull requests targeting `main`.
2. Sets up Java 17 and Flutter 3.47.0.
3. Installs Flutter dependencies.
4. Runs `flutter analyze`.
5. Runs unit, widget, and integration test commands separately.
6. Restores Android signing material at runtime from GitHub Secrets.
7. Authenticates to Google Cloud using GitHub OIDC / Workload Identity Federation.
8. Builds a signed Android release and invokes Firebase App Distribution.
9. Verifies and uploads the APK as a workflow artifact.
10. Removes restored signing files at the end of the job.

### Django backend workflow

File: [`.github/workflows/django-ci.yml`](../../.github/workflows/django-ci.yml)

The workflow configuration:

1. Runs on pushes and pull requests targeting `main`.
2. Starts a PostgreSQL 16 service container with a health check.
3. Sets up Python 3.13 and installs backend dependencies.
4. Runs `python manage.py check`.
5. Runs `python manage.py test` against the PostgreSQL service.

**Evidence boundary:** The workflow YAML files and related commits establish that the automation has been implemented in the repository. They do not, by themselves, prove the result of the latest GitHub Actions run. Before submission, add links or screenshots of recent successful runs if available.

## 5. Verified GitHub Actions results

The latest runs found on the repository's `main` branch during this review were completed successfully on **15 November 2026**:

- [Django CI — successful run](https://github.com/YousefAbaas/Aidora/actions/runs/43721781747): PostgreSQL service container initialised; Python dependencies installed; Django system checks passed; Django tests passed.
- [Flutter CI — successful run](https://github.com/YousefAbaas/Aidora/actions/runs/43721781742): Flutter dependencies installed; static analysis and unit/widget/integration test steps passed; signed Android release build and Firebase App Distribution completed; APK verified and uploaded as an artifact; signing files cleaned up.

These links provide direct evidence that the configured pipelines have run successfully on `main`. They do not mean that the Mozilla preparation branch has been run through CI, and they do not establish real-world beneficiary use of Aidora.

### Additional verified pull-request CI — 24 November 2026

The following workflow runs completed successfully on the pull-request head commits. Each corresponding PR has since been merged into `main`:

- **Backend hardening, PR #1:** [Django CI — run 56](https://github.com/YousefAbaas/Aidora/actions/runs/45071807629) and [Flutter CI — run 73](https://github.com/YousefAbaas/Aidora/actions/runs/45071807554), both successful on commit [dea9096](https://github.com/YousefAbaas/Aidora/commit/dea909640255a68132df9f3025503bd9e6bc5e6e). Merge commit: [05441b9](https://github.com/YousefAbaas/Aidora/commit/05441b9383a2f35e3703fa2c7492dcc2a81b3b77).
- **Android/mobile hardening, PR #3:** [Django CI — run 58](https://github.com/YousefAbaas/Aidora/actions/runs/45073134286) and [Flutter CI — run 75](https://github.com/YousefAbaas/Aidora/actions/runs/45073134396), both successful on commit [6e61193](https://github.com/YousefAbaas/Aidora/commit/6e611930bbe46f88a730e432bbb1c0866ce9e3a2). Merge commit: [490b53b](https://github.com/YousefAbaas/Aidora/commit/490b53ba2ca3737d2f077356dc7ba5601ccd15fb).
- **Ed25519 synthetic approval evidence, PR #9:** [Synthetic Community Policy API CI — run 68](https://github.com/YousefAbaas/Aidora/actions/runs/45272014135), [Django CI — run 83](https://github.com/YousefAbaas/Aidora/actions/runs/45272014009), and [Flutter CI — run 100](https://github.com/YousefAbaas/Aidora/actions/runs/45272013841), all successful on commit [ad29deb](https://github.com/YousefAbaas/Aidora/commit/ad29deb9c6f9459bd8050c858e58b84527bdd210). Merge commit: [af98656](https://github.com/YousefAbaas/Aidora/commit/af986565c59c3791af0740f42e2635bda0109615).

These results verify the tested PR-head changes. They are not a claim that an independent security audit was completed or that a production deployment is secure.

## 6. Security and engineering judgement

The 23 November 2026 internal review identified concrete backend and mobile security gaps. PR #1 and PR #3 subsequently merged remediations for QR authentication/ownership, secure-by-default API permissions, stronger OTP/QR randomness, account-enumeration behavior, production network configuration, and token logging. Further mobile credential-storage and backend authorization work is proposed in open PRs #13 and #14; see section 6.2. The commit history also records removal of a production database dump and rules to ignore database backups, but removal from the working tree did not erase the file from Git history.

These are evidence of security-conscious engineering practices. They should not be described as an independent penetration test, formal security certification, or comprehensive privacy audit.

### 6.1 Internal security review and remediation status — reviewed 23 November; repository status verified 24 November 2026 (AI-assisted, not an independent audit)

**Findings recorded in the 23 November internal review:**

- The QR completion endpoint needed explicit authentication and ownership enforcement.
- OTP generation and volunteer QR identifiers needed stronger randomness.
- The forgot-password endpoint exposed whether an email address was registered.
- The Android release configuration allowed cleartext HTTP too broadly, and mobile logs could expose token-bearing response bodies.
- A production database export (`backend/organizations_prod.sql`) had been removed from the working tree, but remains present in Git history. The file's historical contents were not exhaustively audited.
- Signing-related password strings in older commits (including historical commits `24a4938` and `2d7333d`) have not been verified as placeholders or real credentials.

**Merged remediation and validation:**

| Area | Verified status |
|---|---|
| Backend authentication and authorisation | PR #1 merged in [05441b9](https://github.com/YousefAbaas/Aidora/commit/05441b9383a2f35e3703fa2c7492dcc2a81b3b77). The default DRF permission is `IsAuthenticated`; `ScanQRAPIView` applies `IsRole`, which checks authentication and the allowed role. The PR also adds request ownership checks, cryptographically stronger OTP/QR generation, and a uniform forgot-password response. [Django CI](https://github.com/YousefAbaas/Aidora/actions/runs/45071807629) and [Flutter CI](https://github.com/YousefAbaas/Aidora/actions/runs/45071807554) passed on the PR head. |
| Android/mobile network and logging | PR #3 merged in [490b53b](https://github.com/YousefAbaas/Aidora/commit/490b53ba2ca3737d2f077356dc7ba5601ccd15fb). Release cleartext traffic is disabled; development allowances are isolated to debug configuration; token-bearing refresh response bodies are no longer printed, and response previews are debug-only. [Django CI](https://github.com/YousefAbaas/Aidora/actions/runs/45073134286) and [Flutter CI](https://github.com/YousefAbaas/Aidora/actions/runs/45073134396) passed on the PR head. |
| Synthetic policy API approval verification | PR #9 merged in [af98656](https://github.com/YousefAbaas/Aidora/commit/af986565c59c3791af0740f42e2635bda0109615). The API verifies Ed25519-signed synthetic evidence with configured public keys; the private signing helper is kept separate from API verification. [API CI](https://github.com/YousefAbaas/Aidora/actions/runs/45272014135), [Django CI](https://github.com/YousefAbaas/Aidora/actions/runs/45272014009), and [Flutter CI](https://github.com/YousefAbaas/Aidora/actions/runs/45272013841) passed on the PR head. |

### 6.2 Pending security pull requests — status verified 25 November 2026

The following remediation work is validated by CI on its current pull-request head, but neither PR is merged into `main`:

- **Platform-backed mobile token storage — [PR #13](https://github.com/YousefAbaas/Aidora/pull/13):** moves access/refresh tokens to Android Keystore-backed secure storage and iOS Keychain, adds guarded migration from legacy plaintext storage, and handles refresh-token rotation as a pair. The latest head is `52be870bb41bf3ea3d2b30044ba5699b78dcf8d1`. [Flutter CI run 126](https://github.com/YousefAbaas/Aidora/actions/runs/45557920006) and [Django CI run 109](https://github.com/YousefAbaas/Aidora/actions/runs/45557919689) both completed successfully on that head. PR #13 remains open and under review; do not describe these changes as part of `main` until merged.
- **Backend tenant isolation and verified-account enforcement — [PR #14](https://github.com/YousefAbaas/Aidora/pull/14):** adds broader organization/refugee ownership checks, verified-account requirements for JWT issuance and protected requests, stronger OTP/PIN controls, and safer task/QR authorization transitions. The latest head is `7d262fa80b084bcece1fc982a759cdb16220ab17`. [Django CI run 227](https://github.com/YousefAbaas/Aidora/actions/runs/45596575688) and [Flutter CI run 205](https://github.com/YousefAbaas/Aidora/actions/runs/45596575672) both completed successfully on that head. PR #14 remains a Draft and is not merged; passing CI is not a substitute for review or an independent security audit.

**Residual issues — do not describe these as resolved:**

1. The production database export remains in Git history. No history rewrite, credential rotation, or repository-wide historical secret audit is recorded here.
2. The old signing-related strings have not been classified as genuine or placeholder values. If any were genuine, revoke/rotate them and assess any associated exposure.
3. PR #13 proposes platform-backed token storage, but it is still open and unmerged. Do not claim the migration is already present in `main`.
4. PR #14 contains further backend authorization and account-verification hardening, but it remains a Draft and unmerged. Do not claim those changes are already present in `main`.
5. The work and CI results documented here are engineering evidence, not an independent penetration test, privacy assessment, or security certification.

The issuer-governance and SQLite registry proposals are separate documentation-only drafts in [PR #10](https://github.com/YousefAbaas/Aidora/pull/10) and [PR #11](https://github.com/YousefAbaas/Aidora/pull/11). They are not merged or implemented. Their unresolved authority, recovery, lifecycle, and transaction questions must be reviewed with the accountable host and affected communities before any runtime implementation.

This review was assisted by an AI tool. It is an internal engineering review, not an independent audit.


## 7. What this evidence does — and does not — establish

It supports that the applicant:

- created and owns Aidora;
- led its end-to-end design and principal implementation;
- can work across a mobile client, API backend, database, and delivery pipeline;
- has experience with automated checks, tests, signed builds, and release distribution;
- maintains technical documentation and repository hygiene.

It does **not** establish that Aidora has been deployed by an NGO, has an active verified user base, or generated measured field outcomes. The applicant confirms that, during the initial launch, he spoke directly with refugees and people seeking assistance and received positive initial feedback. No participant count, structured study protocol, written quotations, or measured outcome has been supplied. This should be described as early qualitative feedback, not a formal user study or formal co-design unless additional evidence supports that description.

## 8. Relevance to the Mozilla proposal

Aidora is evidence of transferable software engineering capability, not the proposed mental-health data-governance product itself. The proposed Mozilla project remains a concept that must be validated with SRHIN and affected communities. No integration with GENCurate or GENSCORE, access to sensitive records, or host endorsement should be claimed before explicit approval.
