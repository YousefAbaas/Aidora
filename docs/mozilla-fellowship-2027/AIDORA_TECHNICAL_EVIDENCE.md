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

## 6. Security and engineering judgement

The repository documents environment-based secret configuration, JWT authentication, role checks on most API endpoints (one unauthenticated endpoint was found in the 23 November 2026 review, see 6.1), database SSL/TLS settings for production, and rules against committing local secrets and database exports. The commit history also records removal of a production database dump and rules to ignore database backups.

These are evidence of security-conscious engineering practices. They should not be described as an independent penetration test, formal security certification, or comprehensive privacy audit.

### 6.1 Internal security review — 23 November 2026 (AI-assisted; not an independent audit)

**Findings on `main` at the time of review:**

- The QR completion endpoint (`ScanQRAPIView`) had its permission classes commented out, so it was reachable without authentication; no default DRF permission class was set.
- OTP codes were generated with a non-cryptographic random generator; new volunteer QR codes used only 8 hex characters of randomness.
- The forgot-password endpoint returned different responses for registered and unregistered emails (account enumeration).
- The mobile client logged the token-refresh response body, and the Android network configuration allowed cleartext HTTP for all hosts in release builds.
- A production database export (`backend/organizations_prod.sql`, containing INSERT statements for organisation, service and target-group tables; user tables were not seen in a statement-type count, and the content was not exhaustively audited) was removed from the working tree but remains in Git history. Signing-related password lines in older commits (e.g. `24a4938`, `2d7333d`) have not been verified as placeholders or real values.

**Remediation status (do not describe as fixed until merged and CI is green):**

| Item | Status |
|---|---|
| Backend fixes: pull request #1 (`security/backend-hardening`) | Open, not merged. Django CI passed on commit `dea9096`; Flutter CI result not yet verified. |
| Mobile/Android fixes: branch `fix/flutter-hardening` | Pushed, no pull request yet, not tested with the Flutter toolchain. |
| Git history rewrite for the database export | Not performed (requires owner decision). |
| Signing credentials in history | Owner to verify; rotate if real. |

This review was assisted by an AI tool. It is an internal engineering review, not a penetration test or formal security certification.

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
