# App Store Connect

Uploads of the Portrai iOS app to App Store Connect. `_deploy_appstore.yaml` uploads the signed
production IPA with an App Store Connect API key passed in as repository secrets. This folder holds
the local copy of that key, `AuthKey.p8`.

This folder is git-ignored by `app/portrai/.gitignore`. Never commit the key.

## Prerequisites

- An Apple Developer Program membership with the App ID `com.mayandro.portrai`.
- An app record in App Store Connect for the bundle ID `com.mayandro.portrai`.
- Distribution signing set up as described in the [signing README](../.signing/README.md).

## Setup

### 1. Create the API key

1. In **App Store Connect > Users and Access > Integrations > App Store Connect API**, generate a
   team key with a role that can upload builds, such as **App Manager**.
2. Download the `.p8` file and save it as `AuthKey.p8` in this folder. Apple offers the download
   only once.
3. Note the key's **Key ID** and the team's **Issuer ID** shown on the same page.

### 2. Set the repository secrets

Run these yourself from the workspace root. `gh secret set` without `--body` prompts for the value:

```bash
base64 -i app/portrai/ios/.appstore/AuthKey.p8 | gh secret set PORTRAI_APP_STORE_CONNECT_API_KEY
gh secret set PORTRAI_APP_STORE_CONNECT_API_KEY_ID
gh secret set PORTRAI_APP_STORE_CONNECT_API_ISSUER_ID
gh secret set PORTRAI_APP_STORE_BUNDLE_ID --body com.mayandro.portrai
```

## Usage

### Release

1. Print the next production tag from a clean working tree:

   ```bash
   melos run prepare_portrai_release
   ```

   The script switches to `develop`, pulls it and prints `<version>+<build>-prod`, where
   `<version>` comes from `app/portrai/pubspec.yaml` and `<build>` is one higher than the highest
   build number in the pubspec and the `-review` and `-prod` tags. It does not modify files, commit,
   tag or push.

2. Create and push the printed tag on the release commit:

   ```bash
   git tag 1.0.0+2-prod
   git push origin 1.0.0+2-prod
   ```

The tag starts **Portrai Production Release** (`portrai_production.yaml`), which also releases
Android and web. Its iOS jobs run in this order:

1. `extract-version` reads the version and build number from the tag.
2. `quality` runs `portrai.yaml`.
3. `build-ios` runs `_build_ios.yaml` with the App Store profile and passes the tag's version and
   build number to `--build-name` and `--build-number`.
4. `deploy-appstore` runs `_deploy_appstore.yaml`, which writes the key to
   `~/.appstoreconnect/private_keys/AuthKey_<Key ID>.p8`, uploads `portrai-release.ipa` and always
   deletes the key afterwards:

   ```bash
   xcrun altool --upload-app --type ios --file portrai-release.ipa \
     --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
     --apiIssuer "$APP_STORE_CONNECT_API_ISSUER_ID"
   ```

5. `create-release` creates the GitHub release once every deploy job succeeds.

The upload does not assign TestFlight testers, submit the build for App Review or release it. After
Apple processes the build, do those steps in App Store Connect.

`Info.plist` sets `ITSAppUsesNonExemptEncryption` to `false`, which answers the export compliance
question for each build.

### Preview builds

`*+*-review` tags run `portrai_preview.yaml`, which signs the IPA with the Ad Hoc profile and
distributes it through Firebase App Distribution to the `testers` group. Preview builds do not
reach App Store Connect.

## Configuration

`portrai_production.yaml` passes these repository secrets to `_deploy_appstore.yaml`:

| Secret | Value |
|--------|-------|
| `PORTRAI_APP_STORE_CONNECT_API_KEY` | Base64-encoded `AuthKey.p8` |
| `PORTRAI_APP_STORE_CONNECT_API_KEY_ID` | Key ID of the API key |
| `PORTRAI_APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID of the API key, not the Team ID |
| `PORTRAI_APP_STORE_BUNDLE_ID` | `com.mayandro.portrai`; required by the workflow, the upload reads the bundle ID from the IPA |

The build secrets are listed in the [signing README](../.signing/README.md#configuration).

## Troubleshooting

| Problem | Action |
|---------|--------|
| `Invalid App Store Connect API Key ID` | Set `PORTRAI_APP_STORE_CONNECT_API_KEY_ID` to the letters and digits of the Key ID only |
| Upload fails to authenticate | Check that the Key ID, Issuer ID and `.p8` belong to the same key and that the key is not revoked |
| Upload rejects the build number | Create a new tag with a higher build number; App Store Connect does not accept a build number twice for the same version |

## Related docs

- [Signing README](../.signing/README.md)
- [Releases guide](../../../../.github/RELEASES.md)
- [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios)
