# Aidora CI/CD

## Purpose

Aidora uses GitHub Actions to validate changes and automate delivery of a signed Android release to Firebase App Distribution.

The pipeline is designed around four stages:

```text
Validate → Test → Build & Sign → Distribute
```

## Current pipeline

The Flutter workflow is triggered by pushes and pull requests targeting `main`. It uses Java 17 and Flutter 3.47.0. The workflow runs static analysis, unit tests, widget tests, and integration tests before building the Android release APK. The release is signed from a keystore restored at runtime from GitHub Secrets and then uploaded to Firebase App Distribution.

### Pipeline flow

```text
Git push / Pull Request
        ↓
GitHub Actions runner (Ubuntu)
        ↓
Checkout repository
        ↓
Java 17
        ↓
Google authentication (GitHub OIDC + WIF)
        ↓
Flutter 3.47.0
        ↓
flutter pub get
        ↓
flutter analyze
        ↓
unit tests
        ↓
widget tests
        ↓
integration tests
        ↓
restore release keystore + key.properties
        ↓
Gradle assembleRelease
        ↓
signed app-release.apk
        ↓
Firebase App Distribution
        ↓
qa-testers
```

## Why validation happens before distribution

A release should only be distributed when the source passes automated quality gates. Failing early at analysis or tests avoids spending several minutes on Android compilation and prevents an obviously broken artifact from reaching QA.

## CI vs CD in Aidora

**Continuous Integration (CI)** covers source validation: dependency installation, analysis, and automated tests.

**Continuous Delivery/Deployment (CD)** covers producing the release artifact, signing it, and distributing it to the QA audience.

In Aidora these responsibilities are connected in one GitHub Actions workflow, but they remain logically distinct.

## Release artifact

The Android build produces:

```text
android/app/build/outputs/apk/release/app-release.apk
```

The APK is also uploaded to GitHub Actions as a workflow artifact so the generated file can be retained independently of Firebase distribution.

## Security model

The workflow does not commit the Android signing keystore or Google service-account private key to source control.

- The Android keystore is reconstructed temporarily from GitHub Secrets.
- Google authentication uses GitHub OIDC and Google Workload Identity Federation.
- The authentication action creates temporary credential configuration for the job.
- Cleanup removes the restored keystore and `key.properties` after the job, including after failures.

## Operational principle

The pipeline is considered successful only when the software has passed its validation gates and the signed artifact has been delivered to Firebase App Distribution. A green build without successful distribution is not the complete delivery outcome.

## Current known warnings

The successful workflow still reports dependency/toolchain deprecation warnings from Gradle/Android tooling. These warnings are not currently blocking the pipeline and should be handled as a planned modernization task rather than mixed into the release-signing fix.
