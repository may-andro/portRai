# Releases

Pushing a git tag releases the Portrai app, Storybook or the legal pages. Cloud Functions deploy
on pushes to `develop` instead. Every release workflow lives in [`workflows/`](workflows/).

## Release triggers

| Trigger | Example | Workflow | Releases |
|---------|---------|----------|----------|
| Tag `*+*-review` | `1.1.4+202530-review` | [`portrai_preview.yaml`](workflows/portrai_preview.yaml) | Portrai preview builds for Android, iOS and web |
| Tag `*+*-prod` | `1.1.4+202530-prod` | [`portrai_production.yaml`](workflows/portrai_production.yaml) | Portrai production builds for Android, iOS and web |
| Tag `*+*-review-storybook` | `2.0.0+50-review-storybook` | [`storybook_review.yaml`](workflows/storybook_review.yaml) | Storybook to the `review` Hosting channel |
| Tag `*+*-prod-storybook` | `2.0.0+50-prod-storybook` | [`storybook_production.yaml`](workflows/storybook_production.yaml) | Storybook to the `live` Hosting channel |
| Tag `legal-*` | `legal-1.1.0` | [`legal_production.yaml`](workflows/legal_production.yaml) | Legal pages to the `live` Hosting channel |
| Push to `develop` changing `tool/functions/**` | | [`functions_production.yaml`](workflows/functions_production.yaml) | The `portrai` Cloud Functions codebase |
| Pull request changing `app/storybook/**` or `layer/design_system/**` | | [`storybook_pr.yaml`](workflows/storybook_pr.yaml) | Storybook to the `preview` Hosting channel |

The workflow filters escape the literal `+` (`'*\+*-prod'`); tag names contain no backslash. The
tag-triggered workflows cancel an in-progress run for the same tag. `functions_production.yaml`
lets a running deploy finish before the next one starts.

## Tag format

```text
<version>+<build_number>-<type>[-storybook]
```

| Part | Meaning |
|------|---------|
| `version` | Semantic version, such as `1.1.4`, passed to `--build-name` |
| `build_number` | Integer passed to `--build-number`; Android and App Store Connect reject a build number that was already uploaded |
| `type` | `review` or `prod` |
| `-storybook` | Selects the Storybook workflows |

[`extract-version-build`](actions/extract-version-build/action.yaml) removes the last `-<suffix>`
from the tag and splits the rest at `+`. Only the Portrai workflows use it; Storybook builds take
their version from `app/storybook/pubspec.yaml`, and the legal workflow reads the text after
`legal-`.

## Preparing a Portrai release

From a clean working tree:

```bash
melos run prepare_portrai_release
```

[`tool/release/prepare_portrai_release.sh`](../tool/release/prepare_portrai_release.sh) fetches
tags from `origin`, switches to `develop` and pulls with `--ff-only`. It reads the semantic version
from `app/portrai/pubspec.yaml` and prints `<version>+<build>-prod`, where `<build>` is one more
than the highest build number in the pubspec and in the `<x.y.z>+<n>-review` and `<x.y.z>+<n>-prod`
tags, compared numerically. Storybook and legal tags are ignored. The script does not modify files,
commit, tag or push.

The pubspec build number does not need to match the tag; CI takes both values from the tag.
Semantic version changes are made in `pubspec.yaml`. Create and push the tag on the release
commit:

```bash
git tag 1.1.4+202530-prod
git push origin 1.1.4+202530-prod
```

## Portrai releases

### Job order

Both Portrai workflows run:

1. `extract-version`: reads the version and build number from the tag and generates the
   App Distribution release notes.
2. `quality`: calls [`portrai.yaml`](workflows/portrai.yaml), which writes
   `lib/firebase_options.dart`, generates code, then checks formatting, runs
   `dart analyze --fatal-infos` and runs the tests with coverage.
3. `build-android`, `build-ios` and `build-web`, in parallel, through
   [`_build_android.yaml`](workflows/_build_android.yaml),
   [`_build_ios.yaml`](workflows/_build_ios.yaml) and
   [`_build_web.yaml`](workflows/_build_web.yaml).
4. Deploy jobs, each starting when its build finishes, through
   [`_deploy_firebase.yaml`](workflows/_deploy_firebase.yaml),
   [`_deploy_playstore.yaml`](workflows/_deploy_playstore.yaml) and
   [`_deploy_appstore.yaml`](workflows/_deploy_appstore.yaml).
5. Production only: `create-release`, after every deploy job succeeds.

### Builds

Every build passes the tag's version and build number to `--build-name` and `--build-number`.

| Platform | Preview (`-review`) | Production (`-prod`) |
|----------|---------------------|----------------------|
| Android | `flutter build apk --release`, `build_env=staging`, signed with the upload key | `flutter build appbundle --release`, `build_env=prod`, signed with the upload key |
| iOS | `flutter build ipa --release --no-codesign`, `build_env=staging`, exported with the Ad Hoc profile (method `release-testing`) as `portrai-debug.ipa` | Same build with `build_env=prod`, exported with the App Store profile (method `app-store-connect`) as `portrai-release.ipa` |
| Web | `flutter build web --profile`, `build_env=staging`, `ENVIRONMENT=preview` | `flutter build web --release`, `build_env=prod`, `ENVIRONMENT=production` |

Android and iOS builds run on `ubuntu-latest` and `macos-latest`. The Android build recreates
`android/.signing` from secrets and deletes it afterwards. The iOS build imports the Apple
Distribution certificate into a temporary keychain, installs the profile, signs during
`xcodebuild -exportArchive`, and removes the keychain, profile and decoded files afterwards. The
web build requires the `FIREBASE_APP_CHECK_WEB_SITE_KEY` variable, generates the SQLite web assets
and replaces the `MAPS_API_KEY` placeholder in `build/web/index.html`.

### Distribution

| Build | Preview | Production |
|-------|---------|------------|
| Android APK | Firebase App Distribution, group `testers` | |
| Android AAB | | Google Play `internal` track, and Firebase App Distribution group `production-testers` |
| iOS IPA | Firebase App Distribution, group `testers` | App Store Connect |
| Web | Firebase Hosting, `portrai` target, channel `preview` | Firebase Hosting, `portrai` target, channel `live` |

- The Play deploy uploads the AAB with `r0adkll/upload-google-play@v1`, status `completed`,
  in-app update priority `2` and the R8 `mapping.txt`. It does not upload release notes or store
  listing content.
- The App Store deploy uploads `portrai-release.ipa` with `xcrun altool --upload-app`. It does not
  assign TestFlight testers, submit for App Review or release the build; those steps are done in
  App Store Connect after Apple processes the build.
- Production iOS builds are not sent to Firebase App Distribution.
- Ad Hoc preview IPAs install only on devices registered in the Ad Hoc profile.

### Release notes

`extract-version` builds the release notes that Firebase App Distribution shows testers:

- A header `Version <version> (Build <build>)`, followed by `Preview Build - For Testing Only` or
  `Production Release`.
- The commit subjects since the previous tag of the same kind (`*+*-review` or `*+*-prod`, newest
  by committer date). Without a previous tag, the last 10 (preview) or 20 (production) commits.
- The actor who pushed the tag and the short commit SHA.

### GitHub release

`create-release` in `portrai_production.yaml` creates a GitHub release named `Portrai <tag>` with
`softprops/action-gh-release@v2`. Its body lists `* <subject> (<author>)` for each commit since the
previous `*+*-prod` tag, or every commit reachable from the tag when there is none. Preview tags do
not create a GitHub release.

## Storybook releases

`storybook_review.yaml`, `storybook_production.yaml` and `storybook_pr.yaml` run:

1. `quality`: [`_storybook_quality.yaml`](workflows/_storybook_quality.yaml) runs the format check,
   `flutter analyze` and the unit tests (excluding `golden` tags) as parallel jobs.
2. `build`: `_build_web.yaml` with `force-release`, so every Storybook build is
   `flutter build web --release`. Review and PR builds use `build_env=staging`, production builds
   `build_env=prod`. The version comes from `app/storybook/pubspec.yaml`.
3. `deploy`: `_deploy_firebase.yaml` to the `storybook` Hosting target, channel `review`
   (review tag), `live` (production tag) or `preview` (pull request).

`storybook_production.yaml` also runs
[`_storybook_release_notes.yaml`](workflows/_storybook_release_notes.yaml) after `quality`, in
parallel with the build and deploy. It creates a GitHub release named `Storybook <tag>` listing the
commit subjects since the previous `*+*-prod-storybook` tag, and uploads the changelog as an
artifact kept for 30 days.

## Legal pages releases

`legal_production.yaml` takes the version from the `legal-<version>` tag, replaces `{{VERSION}}`
in every HTML file under `tool/legal/public`, deploys `tool/legal` to the `live` channel of the
`legal` Hosting target, then creates a GitHub release named `Legal Pages v<version>` listing the
commits that touched `tool/legal/` since the previous `legal-*` tag. It has no quality or build
job. See the [legal pages README](../tool/legal/README.md#release).

## Cloud Functions deploys

`functions_production.yaml` runs on pushes to `develop` that change `tool/functions/**` or the
workflow itself. It calls [`functions.yaml`](workflows/functions.yaml) as the quality gate, then
runs `firebase deploy --only functions:portrai --force` with `firebase-tools@15.34.1`. It has no
tag, build or GitHub release. See the
[functions README](../tool/functions/README.md#deploying-from-github-actions).

## Build artifacts

Each build uploads a GitHub Actions artifact named `<app>-<platform>-<build-type>-<commit sha>`:

| Platform | Preview | Production |
|----------|---------|------------|
| Android | `app-release.apk`, 7 days | `app-release.aab` and `mapping.txt`, 30 days |
| iOS | `portrai-debug.ipa`, 7 days | `portrai-release.ipa`, 30 days |
| Web | `build/web/`, 7 days | `build/web/`, 30 days |

Storybook web artifacts follow the web row for their build type.

## Secrets and variables

Repository secrets unless marked as a variable. `GITHUB_TOKEN` is provided by GitHub Actions.

| Name | Value | Read by |
|------|-------|---------|
| `PORTRAI_FIREBASE_OPTIONS` | Contents of `app/portrai/lib/firebase_options.dart`, not encoded | `portrai.yaml`, all Portrai builds |
| `PORTRAI_ANDROID_KEYSTORE_BASE64` | Base64 of the upload keystore (`portrai-release-key.jks`) | Android builds |
| `PORTRAI_ANDROID_KEYSTORE_PASSWORD` | Keystore password | Android builds |
| `PORTRAI_ANDROID_KEY_ALIAS` | Key alias | Android builds |
| `PORTRAI_ANDROID_KEY_PASSWORD` | Key password | Android builds |
| `PORTRAI_GOOGLE_SERVICES_JSON` | Base64 of `android/app/google-services.json` | Android builds |
| `MAPS_API_KEY_ANDROID` | Google Maps API key | Android builds (optional) |
| `PORTRAI_GOOGLE_SERVICES_PLIST` | Base64 of `ios/Runner/GoogleService-Info.plist` | iOS builds |
| `MAPS_API_KEY_IOS` | Google Maps API key | iOS builds (optional) |
| `PORTRAI_IOS_CERTIFICATE_BASE64` | Base64 of the Apple Distribution certificate and private key (`.p12`) | iOS builds |
| `PORTRAI_IOS_CERTIFICATE_PASSWORD` | Password of the `.p12` | iOS builds |
| `PORTRAI_IOS_PROVISIONING_PROFILE_BASE64` | Base64 of the App Store Connect provisioning profile | Production iOS build |
| `PORTRAI_IOS_ADHOC_PROVISIONING_PROFILE_BASE64` | Base64 of the Ad Hoc provisioning profile | Preview iOS build |
| `MAPS_API_KEY_WEB` | Google Maps JavaScript API key | Portrai web builds (optional) |
| `FIREBASE_APP_CHECK_WEB_SITE_KEY` (variable) | Public reCAPTCHA Enterprise site key | Portrai web builds |
| `PORTRAI_FIREBASE_SERVICE_ACCOUNT` | Base64 of a service account JSON with App Distribution access | App Distribution deploys |
| `PORTRAI_FIREBASE_APP_ID_ANDROID` | Android Firebase app ID | Android App Distribution deploys |
| `PORTRAI_FIREBASE_APP_ID_IOS` | iOS Firebase app ID | Preview iOS App Distribution deploy |
| `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` | Base64 of a service account JSON with Hosting deploy access | Portrai web, Storybook and legal deploys |
| `FIREBASE_PROJECT_ID` | Firebase project ID | Hosting deploys and the functions deploy; also passed to App Distribution deploys, which do not use it |
| `PORTRAI_PLAY_STORE_SERVICE_ACCOUNT_JSON` | Base64 of a service account JSON with Play Console release access | Play deploy |
| `PORTRAI_PLAY_STORE_PACKAGE_NAME` | Android package name | Play deploy |
| `PORTRAI_APP_STORE_CONNECT_API_KEY` | Base64 of the App Store Connect API key (`.p8`) | App Store deploy |
| `PORTRAI_APP_STORE_CONNECT_API_KEY_ID` | Key ID of the API key | App Store deploy |
| `PORTRAI_APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID of the API key | App Store deploy |
| `PORTRAI_APP_STORE_BUNDLE_ID` | iOS bundle ID; required by the workflow, while the upload reads the bundle ID from the IPA | App Store deploy |
| `FUNCTIONS_DEPLOY_SERVICE_ACCOUNT` | Base64 of a service account JSON with functions deploy access | Functions deploy |

[`prepare-service-account`](actions/prepare-service-account/action.yaml) decodes every service
account secret, fails unless it is a service account JSON with a private key, masks its values and
writes it to a temporary file that the job deletes afterwards.

## One-time setup

Run these commands yourself. `gh secret set` without `--body` prompts for the value.

### Android signing

Create an upload keystore, then store it and its passwords:

```bash
keytool -genkey -v -keystore portrai-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias portrai-release
base64 -i portrai-release-key.jks | gh secret set PORTRAI_ANDROID_KEYSTORE_BASE64
gh secret set PORTRAI_ANDROID_KEYSTORE_PASSWORD
gh secret set PORTRAI_ANDROID_KEY_ALIAS
gh secret set PORTRAI_ANDROID_KEY_PASSWORD
```

Locally, `app/build.gradle.kts` signs release builds with `android/.signing/portrai-release-key.jks`
and `android/.signing/key.properties` when both exist, and with the debug key otherwise.

### Firebase config files

```bash
gh secret set PORTRAI_FIREBASE_OPTIONS < app/portrai/lib/firebase_options.dart
base64 -i app/portrai/android/app/google-services.json | gh secret set PORTRAI_GOOGLE_SERVICES_JSON
base64 -i app/portrai/ios/Runner/GoogleService-Info.plist | gh secret set PORTRAI_GOOGLE_SERVICES_PLIST
gh variable set FIREBASE_APP_CHECK_WEB_SITE_KEY
```

### iOS signing

1. Enable Push Notifications and App Attest on the App ID, matching `Runner/Runner.entitlements`.
2. Create an Apple Distribution certificate and export it with its private key as a
   password-protected `.p12`.
3. Create an App Store Connect profile and an Ad Hoc profile (with the tester devices) for the
   App ID and certificate. Save them as `portrai-appstore.mobileprovision` and
   `portrai_adhoc.mobileprovision` in `app/portrai/ios/.signing`.

```bash
base64 -i certificate.p12 | gh secret set PORTRAI_IOS_CERTIFICATE_BASE64
gh secret set PORTRAI_IOS_CERTIFICATE_PASSWORD
melos run set_ios_profile_secrets
```

`set_ios_profile_secrets` fails if either profile is missing or lacks the `aps-environment`
entitlement, then sets `PORTRAI_IOS_PROVISIONING_PROFILE_BASE64` and
`PORTRAI_IOS_ADHOC_PROVISIONING_PROFILE_BASE64`. Regenerate the Ad Hoc profile and run it again
after registering new devices.

### App Store Connect

Create a team API key with a role that can upload builds, such as App Manager, and note its Key ID
and Issuer ID:

```bash
base64 -i AuthKey.p8 | gh secret set PORTRAI_APP_STORE_CONNECT_API_KEY
gh secret set PORTRAI_APP_STORE_CONNECT_API_KEY_ID
gh secret set PORTRAI_APP_STORE_CONNECT_API_ISSUER_ID
gh secret set PORTRAI_APP_STORE_BUNDLE_ID
```

### Google Play

1. Create a Google Cloud service account with a JSON key, and enable the Google Play Android
   Developer API (`androidpublisher.googleapis.com`) in its project.
2. Invite the service account email in Play Console **Users and permissions** with permission to
   release to testing tracks.
3. Link the Firebase project to Google Play (**Project settings > Integrations > Google Play**);
   App Distribution accepts AABs only from a linked project.

```bash
base64 -i service-account.json | gh secret set PORTRAI_PLAY_STORE_SERVICE_ACCOUNT_JSON
gh secret set PORTRAI_PLAY_STORE_PACKAGE_NAME
```

### Firebase App Distribution

Create the tester groups with the aliases `testers` and `production-testers`, and a service
account with the Firebase App Distribution Admin role. The app IDs are the `appId` values under
`flutter.platforms` in `app/portrai/firebase.json`.

```bash
base64 -i service-account.json | gh secret set PORTRAI_FIREBASE_SERVICE_ACCOUNT
gh secret set PORTRAI_FIREBASE_APP_ID_ANDROID
gh secret set PORTRAI_FIREBASE_APP_ID_IOS
```

### Firebase Hosting

Create a service account with the Firebase Hosting Admin role. The Hosting targets map to sites in
each folder's `.firebaserc`: `portrai` in `app/portrai`, `storybook` in `app/storybook` and `legal`
in `tool/legal`.

```bash
base64 -i service-account.json | gh secret set FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT
gh secret set FIREBASE_PROJECT_ID
```

### Maps API keys

```bash
gh secret set MAPS_API_KEY_ANDROID
gh secret set MAPS_API_KEY_IOS
gh secret set MAPS_API_KEY_WEB
```

The functions deploy secret is described in the
[functions README](../tool/functions/README.md#deploying-from-github-actions).

## Working with tags

`git tag -l` uses shell globs, so `+` needs no escaping:

```bash
git tag -l '*+*-prod'            # Portrai production
git tag -l '*+*-review'          # Portrai preview
git tag -l '*+*-storybook'       # Storybook
git tag -l 'legal-*'             # Legal pages
```

A failed job can be rerun from the workflow run in GitHub Actions without a new tag. A new upload
to Google Play or App Store Connect needs a new tag with a higher build number.
