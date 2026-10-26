# Google Play Store

Google Play publishing for the Portrai Android app (package `com.mayandro.portrai`). The
production release workflow uploads the signed app bundle to the Play Store's internal testing
track with a Google Cloud service account.

This folder is git-ignored by `app/portrai/android/.gitignore` and `app/portrai/.gitignore`.
Never commit the service-account JSON.

## Setup

### 1. Create a service account and key

1. In [Google Cloud Console](https://console.cloud.google.com/), open **IAM & Admin → Service
   Accounts** in the project that will own the account, and create a service account.
2. Open the account, go to **Keys → Add Key → Create new key**, choose **JSON** and save the
   downloaded file as `service-account.json` in this folder.

### 2. Enable the Google Play Android Developer API

In the same Google Cloud project, open **APIs & Services → Library**, search for
**Google Play Android Developer API** (`androidpublisher.googleapis.com`) and enable it.

### 3. Grant Play Console access

1. Copy the service-account email from **IAM & Admin → Service Accounts**. It matches the JSON's
   `client_email`.
2. In [Google Play Console](https://play.google.com/console), open **Users and permissions →
   Invite new users** and enter that email.
3. Grant access to the app with permission to view app information and release apps to testing
   tracks, then send the invitation. Service accounts do not need to accept it.

### 4. Link Firebase to Google Play

The production workflow also uploads the app bundle to Firebase App Distribution, which accepts
app bundles only when the Firebase project is linked to Google Play.

1. Open **Firebase Console → Project settings → Integrations → Google Play** and link the app
   with package name `com.mayandro.portrai`.
2. Open **Firebase Console → App Distribution**, select the Android app and complete any setup
   prompts.

## Usage

Pushing a `*+*-prod` tag runs `.github/workflows/portrai_production.yaml` (see the
[releases guide](../../../../.github/RELEASES.md) for the tag format). Its `deploy-playstore` job
runs after `build-android` and calls `.github/workflows/_deploy_playstore.yaml`, which:

1. Downloads the build artifact (`bundle/release/app-release.aab` and
   `mapping/release/mapping.txt`).
2. Decodes `PLAY_STORE_SERVICE_ACCOUNT_JSON` with `.github/actions/prepare-service-account`,
   which fails unless the JSON is a service-account key with a private key, and writes it to a
   temporary file.
3. Uploads the bundle with `r0adkll/upload-google-play@v1` to the `internal` track, with status
   `completed`, in-app update priority `2` and the R8 mapping file.
4. Deletes the temporary credentials file, whether or not the upload succeeded.

`*+*-review` tags build an APK for Firebase App Distribution and do not deploy to Google Play.

The deploy workflow does not read any file in this folder. It does not upload release notes or
store listing content.

## Configuration

`portrai_production.yaml` passes these repository secrets to `_deploy_playstore.yaml`:

| Secret | Value |
|--------|-------|
| `PORTRAI_PLAY_STORE_SERVICE_ACCOUNT_JSON` | Base64-encoded `service-account.json` |
| `PORTRAI_PLAY_STORE_PACKAGE_NAME` | `com.mayandro.portrai`, the `applicationId` in `app/build.gradle.kts` |

Set them with the GitHub CLI from this folder:

```bash
base64 -i service-account.json | gh secret set PORTRAI_PLAY_STORE_SERVICE_ACCOUNT_JSON
gh secret set PORTRAI_PLAY_STORE_PACKAGE_NAME --body com.mayandro.portrai
```

The bundle is signed with the keys described in the [signing README](../.signing/README.md).

## Troubleshooting

**"The caller does not have permission"**
- Check that the JSON's `client_email` is listed under Play Console **Users and permissions**
  with access to the app and permission to release to testing tracks.
- Permission changes can take several minutes to apply. Rerun the failed `deploy-playstore` job;
  a new tag is not needed.

**"Google Play Android Developer API has not been used or is disabled"**
- Enable `androidpublisher.googleapis.com` in the Google Cloud project that owns the service
  account, then rerun the failed job.

**"Your Firebase project needs to be connected to your Google Play developer account"**
- This comes from the `deploy-android-firebase` job. Link Google Play as described in
  [step 4](#4-link-firebase-to-google-play), then rerun that job.

**"Package not found"**
- Check that `PORTRAI_PLAY_STORE_PACKAGE_NAME` is exactly `com.mayandro.portrai`.

**"Expected service-account JSON with a private key." or "Service-account credentials must be
valid JSON."**
- `PORTRAI_PLAY_STORE_SERVICE_ACCOUNT_JSON` does not decode to a service-account key. Set it again
  with the command above.
