# Engineering Decisions

This document records the reasoning behind important implementation choices in Aidora. The goal is to preserve the **why**, not only the final configuration.

## ADR-001 — Use GitHub Actions for release automation

**Context**

Aidora needs repeatable validation and Android release delivery without relying on a developer's local machine.

**Decision**

Use GitHub Actions as the CI/CD execution environment.

**Why**

- Reproducible runner environment.
- Automated validation on pushes and pull requests.
- Native integration with GitHub repository permissions and OIDC.
- A single auditable workflow from source change to QA artifact.

**Consequence**

The workflow must explicitly provision Java, Flutter, signing material, and Google authentication instead of depending on developer-machine configuration.

---

## ADR-002 — Keep Android signing credentials outside Git

**Context**

Release signing requires private key material.

**Decision**

Keep the keystore and `key.properties` outside source control and reconstruct them only during CI execution.

**Why**

This reduces the chance of exposing long-lived release credentials through the repository or Git history.

**Consequence**

GitHub Secrets become part of the release infrastructure and the workflow must clean up runtime files.

---

## ADR-003 — Use Workload Identity Federation instead of a long-lived Google JSON key

**Context**

GitHub Actions must authenticate to Google Cloud and Firebase.

**Alternatives**

1. Store a service-account private JSON key as a GitHub Secret.
2. Use GitHub OIDC with Google Workload Identity Federation.

**Decision**

Use Workload Identity Federation.

**Why**

The design avoids introducing a long-lived private service-account key into GitHub Secrets and instead uses federated identity and short-lived credentials.

**Consequence**

The Google Cloud provider mapping and IAM bindings become part of the system's security configuration and must be documented and maintained carefully.

---

## ADR-004 — Use the Firebase App Distribution Gradle plugin

**Context**

The original Firebase CLI path failed at authentication even though GitHub-to-Google federation itself was working.

**Decision**

Use the Firebase App Distribution Gradle plugin and its `appDistributionUploadRelease` task.

**Why**

The distribution operation is closely coupled to the Android release build, and the plugin provides a Gradle-native upload task.

**Consequence**

Firebase credentials must be correctly exposed to the Gradle process through `GOOGLE_APPLICATION_CREDENTIALS` / the configured credentials path.

---

## ADR-005 — Keep tester distribution group-based

**Context**

A release needs a predictable QA audience.

**Decision**

Distribute through the Firebase App Distribution group alias `qa-testers`.

**Why**

A group gives the pipeline a stable target while allowing membership to change independently of the build configuration.

**Consequence**

The group alias must remain valid in Firebase, and QA membership is managed in Firebase rather than in the Android project.

---

## ADR-006 — Upload the APK as a GitHub Actions artifact too

**Context**

Firebase is the QA distribution channel, but the build output is also useful for debugging and traceability.

**Decision**

Upload `app-release.apk` as a GitHub Actions artifact after a successful build/distribution step.

**Why**

It provides a second auditable copy of the generated artifact associated with the workflow run.

**Consequence**

Artifact retention becomes part of CI storage policy and should be reviewed later if storage needs change.
