# Android Release Signing

## Purpose

Android release signing establishes the identity associated with a release artifact. Aidora signs its release APK during the Gradle build so the artifact distributed to QA is a properly signed release build.

## Key concepts

### Keystore

A keystore is the container used by the Java/Android signing tooling to store signing keys.

Aidora uses a local keystore named:

```text
aidora-release-key.jks
```

The same keystore is made available to CI temporarily; it is not stored in Git.

### Key alias

The alias identifies the signing key entry inside the keystore.

Aidora uses:

```text
keyAlias = aidora-key
```

### Store password

Protects access to the keystore container.

### Key password

Protects the private key entry identified by the alias.

### key.properties

Gradle reads signing values from `android/key.properties`. This file is environment-specific and contains secrets, so it is ignored by Git.

Example shape (values intentionally omitted):

```properties
storePassword=<secret>
keyPassword=<secret>
keyAlias=aidora-key
storeFile=aidora-release-key.jks
```

## Local signing flow

```text
key.properties
      ↓
signingConfigs.release
      ↓
buildTypes.release
      ↓
assembleRelease
      ↓
signed app-release.apk
```

The local release build was verified with Android's signing verification tooling and reported a valid v2 APK signature.

## CI signing flow

CI cannot rely on a developer's local files. The workflow reconstructs them at runtime:

```text
GitHub Secret: ANDROID_KEYSTORE_BASE64
            ↓
base64 decode
            ↓
android/app/aidora-release-key.jks

GitHub Secrets for passwords/alias
            ↓
android/key.properties
            ↓
Gradle release signing
```

The workflow then deletes both runtime files during cleanup.

## Why the keystore must not be committed

The keystore participates in application identity and release signing. Treating it as source code would expose a long-lived private credential to every repository clone and to Git history.

The repository ignores:

```text
*.jks
android/key.properties
```

## Engineering decision

The selected design separates **source code** from **release credentials**. Developers can build locally when they have the local signing material, while CI receives the minimum required signing material only for the duration of a job.
