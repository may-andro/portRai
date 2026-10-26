# Firebase App Distribution

Local credentials and helper files for distributing Portrai Android and iOS builds to testers
through Firebase App Distribution. The whole `.firebase_distribution/` folder is git-ignored
(`app/portrai/.gitignore`), and no workflow reads from it: CI gets the same credentials from
GitHub secrets.

## Contents

| File | Purpose |
|------|---------|
| `service-account.json` | Service account key with App Distribution access, for local CLI uploads |
| `service-account-base64.txt` | Base64 copy of the key, the format the `PORTRAI_FIREBASE_SERVICE_ACCOUNT` secret expects |
| `release-notes.txt` | Release notes template for local uploads with `--release-notes-file` |
| `tester-groups.txt` | Local notes on tester groups and emails; nothing reads it |

## Prerequisites

- App Distribution enabled in the Firebase project `portrai-96f2b` (the default project in
  `app/portrai/.firebaserc`).
- Tester groups with the aliases `testers` and `production-testers` in the Firebase Console
  (App Distribution > Testers & Groups). CI distributes to these aliases.
- A service account in the same Google Cloud project with the Firebase App Distribution Admin
  role, and a JSON key saved here as `service-account.json`.
- The Firebase CLI, for local uploads.

## Usage

### CI

The release workflows call `.github/workflows/_deploy_firebase.yaml` (job `deploy-mobile`), which
uses `wzieba/Firebase-Distribution-Github-Action@v1`:

| Workflow | Tag | Platform | File | Group |
|----------|-----|----------|------|-------|
| `portrai_preview.yaml` | `*+*-review` | Android | `app-release.apk` | `testers` |
| `portrai_preview.yaml` | `*+*-review` | iOS | `portrai-debug.ipa` | `testers` |
| `portrai_production.yaml` | `*+*-prod` | Android | `app-release.aab` | `production-testers` |

Production iOS builds go to App Store Connect through `_deploy_appstore.yaml`, not App
Distribution.

The deploy job:

1. Downloads the build artifact from `_build_android.yaml` or `_build_ios.yaml`.
2. Uses the release notes passed by the calling workflow, or `Build <sha> - Type: <build-type> - By: <actor>` when none are passed.
3. Decodes `PORTRAI_FIREBASE_SERVICE_ACCOUNT` to a temporary file with
   `.github/actions/prepare-service-account`.
4. Uploads the APK, AAB or IPA to the app ID for that platform and group.
5. Deletes the credentials file, even when an earlier step fails.

### Release notes

The `extract-version` job in each release workflow builds the notes from `git log`:

- The header is `Version <version> (Build <build>)`, then `Preview Build - For Testing Only` or
  `Production Release`.
- The body lists commit subjects since the previous tag of the same kind (`*+*-review` or
  `*+*-prod`, newest by committer date). Without a previous tag it lists the last 10 (preview)
  or 20 (production) commits.
- The footer names the actor who pushed the tag and the short commit SHA.

`release-notes.txt` is not used by CI.

### Local upload

From `app/portrai`, build the app, then upload it with the Firebase CLI. The app IDs are the
`appId` values for `android` and `ios` under `flutter.platforms` in `app/portrai/firebase.json`.

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/.firebase_distribution/service-account.json"

flutter build apk --release --dart-define=build_env=staging
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <android-app-id> \
  --groups testers \
  --release-notes-file .firebase_distribution/release-notes.txt
```

Running `firebase login` instead of setting `GOOGLE_APPLICATION_CREDENTIALS` also works. An iOS
upload needs a signed IPA; see the [iOS signing README](../ios/.signing/README.md).

## Configuration

GitHub Actions secrets used by the App Distribution deploy jobs:

| Secret | Value |
|--------|-------|
| `PORTRAI_FIREBASE_SERVICE_ACCOUNT` | Base64-encoded service account JSON |
| `PORTRAI_FIREBASE_APP_ID_ANDROID` | Android app ID from `firebase.json` |
| `PORTRAI_FIREBASE_APP_ID_IOS` | iOS app ID from `firebase.json` |
| `FIREBASE_PROJECT_ID` | Passed to the job; only the web deploy uses it |

To set the service account secret, run from this folder:

```bash
base64 -i service-account.json | gh secret set PORTRAI_FIREBASE_SERVICE_ACCOUNT
```

## Troubleshooting

`.github/actions/prepare-service-account` stops the deploy with one of these errors when the
secret is wrong:

- `Service-account credentials must be valid JSON.`: the secret is not base64 of the JSON key,
  or was encoded twice.
- `Expected service-account JSON with a private key.`: the decoded JSON is not a service account
  key (its `type` is not `service_account`, or it has no `private_key`).
