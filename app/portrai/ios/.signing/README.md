# iOS Code Signing

Distribution signing for the Portrai iOS app. `_build_ios.yaml` signs the IPA in CI with an Apple
Distribution certificate and a provisioning profile passed in as repository secrets. This folder
holds the local copies those secrets are created from.

This folder is git-ignored by `app/portrai/.gitignore`. Never commit its files.

## App details

| Setting | Value | Source |
|---------|-------|--------|
| Bundle ID | `com.mayandro.portrai` | `PRODUCT_BUNDLE_IDENTIFIER` in `Runner.xcodeproj` |
| Minimum iOS version | `15.0` | `IPHONEOS_DEPLOYMENT_TARGET`, `Podfile` |
| Devices | iPhone and iPad | `TARGETED_DEVICE_FAMILY = "1,2"` |
| Entitlements | Push Notifications (`aps-environment`), App Attest | `Runner/Runner.entitlements` |
| Local signing | Automatic, with the project's `DEVELOPMENT_TEAM` | `Runner.xcodeproj` |

## Setup

CI signing uses these files from this folder:

| File | Contents | Used by |
|------|----------|---------|
| `certificate.p12` | Apple Distribution certificate and its private key | Preview and production builds |
| `portrai-appstore.mobileprovision` | App Store Connect distribution profile | Production builds |
| `portrai_adhoc.mobileprovision` | Ad Hoc distribution profile | Preview builds |

### 1. Enable the App ID capabilities

In **Apple Developer > Certificates, Identifiers & Profiles > Identifiers**, open the explicit
App ID `com.mayandro.portrai` and enable **Push Notifications** and **App Attest** to match
`Runner.entitlements`. Profiles generated before a capability is enabled do not include it, so
regenerate both profiles after changing capabilities.

### 2. Create the distribution certificate

1. In Keychain Access, choose **Certificate Assistant > Request a Certificate From a Certificate
   Authority** and save the certificate signing request to disk.
2. In **Certificates**, click **+**, choose **Apple Distribution** and upload the request.
3. Download the certificate and open it to add it to the same keychain.
4. In **My Certificates**, export the certificate together with its private key as
   `certificate.p12` in this folder, protected by a password.

Export from the Mac that created the signing request; a `.cer` file alone has no private key.

### 3. Create the App Store profile

In **Profiles**, click **+**, choose **App Store Connect**, select the App ID
`com.mayandro.portrai` and the Apple Distribution certificate, then save the download as
`portrai-appstore.mobileprovision` in this folder.

### 4. Create the Ad Hoc profile

Register tester devices under **Devices**. In **Profiles**, click **+**, choose **Ad Hoc**, select
the same App ID and certificate and the tester devices, then save the download as
`portrai_adhoc.mobileprovision` in this folder. Only devices in this profile can install preview
builds; regenerate it and update its secret after adding devices.

## Usage

### Build in CI

`portrai_production.yaml` (`*+*-prod` tags) and `portrai_preview.yaml` (`*+*-review` tags) call
`_build_ios.yaml` on `macos-latest`. Its signing steps:

1. Decode the certificate and profile into `$RUNNER_TEMP/portrai-signing`.
2. Read the profile's UUID, team ID and bundle ID, and generate `ExportOptions.plist` with manual
   signing, the `Apple Distribution` certificate and method `app-store-connect` for production or
   `release-testing` for preview.
3. Import the certificate into a temporary keychain and install the profile in
   `~/Library/MobileDevice/Provisioning Profiles/<UUID>.mobileprovision`.
4. Write `MAPS_API_KEY` to `ios/Flutter/Secrets.xcconfig`, then build an unsigned archive:

   ```bash
   flutter build ipa --release --no-codesign \
     --dart-define=build_env=<prod|staging> \
     --build-name=<version> --build-number=<build>
   ```

5. Sign during export with `xcodebuild -exportArchive` and upload `portrai-release.ipa`
   (production, kept 30 days) or `portrai-debug.ipa` (preview, kept 7 days) as the
   `portrai-ios-<build-type>-<sha>` artifact.
6. Always remove the keychain, the installed profile and the decoded files.

Production IPAs go to App Store Connect, see the [App Store README](../.appstore/README.md).
Preview IPAs go to Firebase App Distribution.

### Build locally

The Xcode project uses automatic signing, so local builds sign with the developer's own Xcode
account and do not read this folder:

```bash
flutter build ipa --release
```

### Verify

Run these yourself to check a profile's expiry and push entitlement, and the signing identities in
your keychain:

```bash
security cms -D -i app/portrai/ios/.signing/portrai-appstore.mobileprovision \
  | grep -A1 -E "ExpirationDate|aps-environment"
security find-identity -v -p codesigning
```

## Configuration

`portrai_production.yaml` and `portrai_preview.yaml` pass these repository secrets to
`_build_ios.yaml`:

| Secret | Value | Workflow |
|--------|-------|----------|
| `PORTRAI_IOS_CERTIFICATE_BASE64` | Base64-encoded `certificate.p12` | Both |
| `PORTRAI_IOS_CERTIFICATE_PASSWORD` | Password of `certificate.p12` | Both |
| `PORTRAI_IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded `portrai-appstore.mobileprovision` | Production |
| `PORTRAI_IOS_ADHOC_PROVISIONING_PROFILE_BASE64` | Base64-encoded `portrai_adhoc.mobileprovision` | Preview |
| `PORTRAI_FIREBASE_OPTIONS` | Contents of `lib/firebase_options.dart`, not encoded | Both |
| `PORTRAI_GOOGLE_SERVICES_PLIST` | Base64-encoded `ios/Runner/GoogleService-Info.plist` | Both |
| `MAPS_API_KEY_IOS` | Google Maps API key (optional) | Both |

Set the certificate secrets with the GitHub CLI from this folder. `gh secret set` without `--body`
prompts for the value:

```bash
base64 -i certificate.p12 | gh secret set PORTRAI_IOS_CERTIFICATE_BASE64
gh secret set PORTRAI_IOS_CERTIFICATE_PASSWORD
```

Set both profile secrets from the workspace root. The script fails if either profile is missing
from this folder or has no `aps-environment` entitlement:

```bash
melos run set_ios_profile_secrets
```

## Troubleshooting

| Message | Action |
|---------|--------|
| `The distribution certificate, password, and provisioning profile are required` | Set the certificate secrets and the profile secret the workflow uses |
| `Invalid provisioning profile UUID` | Re-encode and set the profile secret from a valid `.mobileprovision` file |
| `Expected exactly one exported signed IPA` | Check that the profile matches the certificate, bundle ID and capabilities, then check the `xcodebuild -exportArchive` output |
| `<profile> has no push entitlement` | Enable Push Notifications for the App ID, regenerate the profile and run `melos run set_ios_profile_secrets` again |

## Related docs

- [App Store README](../.appstore/README.md)
- [Releases guide](../../../../.github/RELEASES.md)
- [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios)
