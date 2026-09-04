# Firebase App Distribution

## Purpose

Aidora uses Firebase App Distribution as the QA delivery target for signed Android release APKs.

Current Firebase application configuration:

```text
Firebase project: Aidora
Project ID: aidora-a6e20
Project number: 241847633661
Android package: com.aidora.app
Firebase Android App ID: 1:241847633661:android:14fa718e2c43121ea92094
Tester group alias: qa-testers
```

## Gradle integration

The Android project uses the Firebase App Distribution Gradle plugin:

```gradle
id "com.google.firebase.appdistribution" version "5.3.0" apply false
```

The application module applies the plugin and configures the release distribution:

```gradle
firebaseAppDistribution {
    appId = "1:241847633661:android:14fa718e2c43121ea92094"
    artifactType = "APK"
    groups = "qa-testers"
    releaseNotes = "Automated release from GitHub Actions"
    serviceCredentialsFile = System.getenv("GOOGLE_APPLICATION_CREDENTIALS")
}
```

The workflow executes:

```bash
bash gradlew assembleRelease appDistributionUploadRelease --no-daemon
```

## Authentication architecture

Aidora does not store a long-lived service-account private key in the repository.

```text
GitHub Actions
    ↓
GitHub OIDC token
    ↓
Google Workload Identity Provider
    ↓
Workload Identity Federation
    ↓
github-actions-firebase service account
    ↓
temporary credential configuration
    ↓
GOOGLE_APPLICATION_CREDENTIALS
    ↓
Firebase App Distribution Gradle plugin
```

## Service account

Aidora uses:

```text
github-actions-firebase@aidora-a6e20.iam.gserviceaccount.com
```

The service account is assigned the Firebase App Distribution Admin role needed by the distribution workflow.

## Workload Identity Federation

The provider is configured in Google Cloud under the `github-actions` workload identity pool. The GitHub repository identity is constrained to the Aidora repository.

The intended security boundary is:

```text
GitHub repository: YousefAbaas/Aidora
```

This prevents unrelated repositories from using the same federation path merely because they run GitHub Actions.

## Tester groups

Firebase App Distribution distributes the release to the group alias:

```text
qa-testers
```

The group must exist for the target Firebase Android app, and it should contain the intended QA testers.

## Why Gradle instead of Firebase CLI

The initial CI design attempted Firebase CLI authentication with the federated credentials. That path reached authentication setup but did not work reliably for the intended distribution command.

The implementation was moved to the Firebase App Distribution Gradle plugin. This keeps Android artifact creation and App Distribution upload in the same Gradle build flow and provides the `appDistributionUploadRelease` task directly.

## Verified outcome

The successful GitHub Actions run demonstrated that the complete path can authenticate, build the signed release, invoke `appDistributionUploadRelease`, and complete the workflow successfully.
