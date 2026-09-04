# CI/CD Troubleshooting Record

This is the engineering record of significant failures encountered while building the Aidora Android CI/CD path.

## 1. `keytool` / Java command confusion

**Symptom**

The signing key creation process initially used an incorrect command/path approach.

**Root cause**

The Java key-management tooling was not being invoked with the correct executable and expected arguments.

**Resolution**

Use the JDK's `keytool` utility explicitly and verify that the generated keystore can be consumed by Gradle.

**Lesson**

Treat signing material as infrastructure and validate it independently before debugging CI.

---

## 2. Local signing path mismatch

**Symptom**

Gradle expected the keystore in a different path from the one supplied by `key.properties`.

**Root cause**

The path was resolved relative to the Android project while the file had been generated elsewhere.

**Resolution**

Align `storeFile` with the actual runtime location and use the same layout in CI.

**Lesson**

File paths in Gradle are part of the build contract; local and CI layouts should be intentionally equivalent.

---

## 3. Generated Android/CMake files appeared in Git status

**Symptom**

Files under `android/app/.cxx/...` appeared as modified after Android builds.

**Root cause**

They are generated build artifacts rather than source files.

**Resolution**

Do not stage them; restore/remove generated changes and keep source control focused on reproducible inputs.

**Lesson**

A clean Git status is an engineering signal. Generated build state should not become part of source history.

---

## 4. Firebase CLI authentication failed with WIF

**Symptom**

GitHub Actions successfully created a Google federated credential configuration, but the Firebase CLI reported that the user was not authenticated.

**Root cause**

The chosen Firebase CLI authentication path did not consume the federated credentials in the expected way for the distribution command.

**Resolution**

Move distribution to the Firebase App Distribution Gradle plugin and explicitly provide the credentials path to Gradle.

**Lesson**

An authentication mechanism can be valid while a specific client still fails to consume it. Validate the complete application-to-API path, not only the identity exchange.

---

## 5. Gradle task not found

**Symptom**

`appDistributionUploadRelease` was unavailable.

**Root cause**

The Firebase App Distribution Gradle plugin had not yet been applied/configured.

**Resolution**

Add the plugin to `android/settings.gradle` and `android/app/build.gradle`.

**Verification**

Gradle then exposed tasks including:

```text
appDistributionUploadDebug
appDistributionUploadProfile
appDistributionUploadRelease
```

**Lesson**

When a Gradle task is missing, verify plugin registration before changing the task invocation itself.

---

## 6. Credentials file path did not exist

**Symptom**

Firebase Gradle plugin reported:

```text
Service credentials file does not exist.
```

and referenced a path named `firebase-service-account.json` that was not created by the workflow.

**Root cause**

The Gradle plugin was not explicitly pointed at the credentials file produced by the Google authentication action.

**Resolution**

Use:

```gradle
serviceCredentialsFile = System.getenv("GOOGLE_APPLICATION_CREDENTIALS")
```

and expose the credentials file path returned by `google-github-actions/auth@v3` to the Gradle process.

**Lesson**

Environment variables are part of the interface between GitHub Actions steps and build tooling.

---

## 7. Access token request failed

**Symptom**

After the credentials path was corrected, Firebase reported:

```text
Error requesting access token
```

**Root cause**

The remaining issue was in the Google Workload Identity/IAM configuration rather than the Android build.

**Resolution**

Correct the workload identity attribute mapping and repository-scoped service-account binding so the GitHub repository could impersonate the intended service account.

**Lesson**

Separate authentication failures into layers: credentials file creation, token exchange, service-account impersonation, and API authorization.

---

## 8. Firebase App Distribution returned HTTP 404

**Symptom**

The upload task reported:

```text
App Distribution halted because it had a problem adding testers/groups:
[404] Requested entity was not found.
```

**Investigation**

The Firebase console showed that App Distribution was enabled for `com.aidora.app` and that the `qa-testers` group existed.

**Resolution**

Ensure the target tester group exists for the correct Firebase application and contains the intended testers.

**Lesson**

A `404` from a service API does not always mean the endpoint is wrong. The target resource (application, release, group, tester) must be validated independently.

---

## Final verification

The corrected configuration completed the full workflow successfully:

```text
analyze-and-test
        ↓
Flutter analysis + tests
        ↓
release APK build
        ↓
release signing
        ↓
Firebase App Distribution upload
        ↓
qa-testers
        ↓
GitHub Actions job succeeded
```
