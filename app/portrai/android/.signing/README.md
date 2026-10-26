# Android Signing

Release signing for the Portrai Android app. `app/build.gradle.kts` reads the upload keystore and
its passwords from this folder, both for local builds and in CI.

This folder is git-ignored by `app/portrai/android/.gitignore` and `app/portrai/.gitignore`.
Never commit the keystore or `key.properties`.

## Setup

The release signing config expects two files in this folder:

| File | Contents |
|------|----------|
| `portrai-release-key.jks` | Upload keystore |
| `key.properties` | `storePassword`, `keyPassword` and `keyAlias` |

### 1. Generate the keystore

```bash
cd app/portrai/android/.signing
keytool -genkey -v -keystore portrai-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias portrai-release
```

`keytool` prompts for the keystore password, the key password and the certificate's name fields.

### 2. Create `key.properties`

Copy `key.properties.template` to `key.properties` and fill in the passwords from step 1:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=portrai-release
```

## Usage

### How signing is selected

The `release` build type uses the `release` signing config when both
`.signing/portrai-release-key.jks` and `.signing/key.properties` exist. If either file is
missing, release builds are signed with the debug key, which Google Play rejects.

### Build locally

From `app/portrai`:

```bash
# App bundle, as built by the production workflow
flutter build appbundle --release --dart-define=build_env=prod

# APK, as built by the preview workflow
flutter build apk --release --dart-define=build_env=staging
```

### Build in CI

`.github/workflows/_build_android.yaml` recreates this folder on the runner before building:

1. Decodes `ANDROID_KEYSTORE_BASE64` into `android/.signing/portrai-release-key.jks`.
2. Writes `android/.signing/key.properties` from `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_PASSWORD` and `ANDROID_KEY_ALIAS`.
3. Builds a signed APK (`build-type: preview`) or app bundle (`build-type: production`) with
   `--build-name` and `--build-number` taken from the release tag.
4. Deletes `android/.signing`, whether or not the build succeeded.

`portrai_preview.yaml` (`*+*-review` tags) and `portrai_production.yaml` (`*+*-prod` tags) both
call this workflow.

### Verify

```bash
# Inspect the keystore
keytool -list -v -keystore app/portrai/android/.signing/portrai-release-key.jks

# Check the APK signature (apksigner ships with the Android SDK build-tools)
apksigner verify --print-certs app/portrai/build/app/outputs/flutter-apk/app-release.apk

# Check the app bundle signature
jarsigner -verify -verbose -certs app/portrai/build/app/outputs/bundle/release/app-release.aab
```

## Configuration

`portrai_preview.yaml` and `portrai_production.yaml` pass these repository secrets to
`_build_android.yaml`:

| Secret | Value |
|--------|-------|
| `PORTRAI_ANDROID_KEYSTORE_BASE64` | Base64-encoded `portrai-release-key.jks` |
| `PORTRAI_ANDROID_KEYSTORE_PASSWORD` | `storePassword` from `key.properties` |
| `PORTRAI_ANDROID_KEY_ALIAS` | `keyAlias` from `key.properties` |
| `PORTRAI_ANDROID_KEY_PASSWORD` | `keyPassword` from `key.properties` |

Set them with the GitHub CLI from this folder. `gh secret set` without `--body` prompts for the
value:

```bash
base64 -i portrai-release-key.jks | gh secret set PORTRAI_ANDROID_KEYSTORE_BASE64
gh secret set PORTRAI_ANDROID_KEYSTORE_PASSWORD
gh secret set PORTRAI_ANDROID_KEY_ALIAS
gh secret set PORTRAI_ANDROID_KEY_PASSWORD
```

## Related docs

- [Play Store README](../.playstore/README.md)
- [Releases guide](../../../../.github/RELEASES.md)
- [Flutter Android deployment](https://docs.flutter.dev/deployment/android)
- [Android app signing](https://developer.android.com/studio/publish/app-signing)
