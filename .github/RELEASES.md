# Release Guide

Complete guide for releasing Portrai app and Storybook using Git tags.

---

## 📌 Quick Reference

### Tag Format
```
VERSION+BUILD_NUMBER-TYPE[-suffix]
```

### Examples

**Portrai App:**
```bash
# Review build
git tag 1.0.0+100-review && git push origin 1.0.0+100-review

# Production build
git tag 1.0.0+100-prod && git push origin 1.0.0+100-prod
```

**Storybook:**
```bash
# Review build
git tag 2.0.0+50-review-storybook && git push origin 2.0.0+50-review-storybook

# Production build
git tag 2.0.0+50-prod-storybook && git push origin 2.0.0+50-prod-storybook
```

### What Happens
1. **Extract** - Version & build number extracted from tag
2. **Quality** - Format checks, analysis, tests
3. **Build** - All platforms with version/build injected
4. **Deploy** - Firebase App Distribution + Hosting
5. **Release** *(prod only)* - GitHub release with changelog

---

## 🎯 Release Patterns

### Portrai App

#### Review Builds (`*+*-review`)
**Example:** `1.1.4+202530-review`

Builds debug versions for testing:
- **Android**: Debug APK
- **iOS**: Debug IPA (no codesign)
- **Web**: Profile build
- **Deploy**: Firebase App Distribution (testers) + Hosting (preview channel)
- **Version**: Auto-injected from tag

**What runs:**
1. Extract version (1.1.4) and build (202530)
2. Quality checks (format, analyze, test)
3. Build Android APK with `--build-name=1.1.4 --build-number=202530`
4. Build iOS IPA with `--build-name=1.1.4 --build-number=202530`
5. Build Web with `--dart-define=VERSION=1.1.4 --dart-define=BUILD_NUMBER=202530`
6. Deploy to Firebase (testers group + preview channel)

#### Production Builds (`*+*-prod`)
**Example:** `1.1.4+202530-prod`

Builds release versions for production:
- **Android**: Release AAB (Play Store)
- **iOS**: Release IPA (requires codesign)
- **Web**: Release build
- **Deploy**: Firebase App Distribution (production) + Hosting (live channel)
- **Release**: GitHub release with changelog
- **Version**: Auto-injected from tag

**What runs:**
1. Extract version (1.1.4) and build (202530)
2. Quality checks (format, analyze, test)
3. Build Android AAB with version/build
4. Build iOS IPA with version/build (requires code signing)
5. Build Web with version/build
6. Deploy to Firebase (production + live channel)
7. Create GitHub release with auto-generated changelog

### Storybook

#### Review Builds (`*+*-review-storybook`)
**Example:** `2.0.0+100-review-storybook`

- **Build**: Web release
- **Deploy**: Firebase Hosting (review channel)

#### Production Builds (`*+*-prod-storybook`)
**Example:** `2.0.0+100-prod-storybook`

- **Build**: Web release
- **Deploy**: Firebase Hosting (live channel)
- **Release**: GitHub release with changelog

---

## 🏗️ Tag Format Details

### Components

```
VERSION + BUILD_NUMBER - TYPE [ -suffix ]
   ↓          ↓           ↓        ↓
 1.1.4   +  202530    -  prod  -storybook
```

- **VERSION**: Semantic versioning (MAJOR.MINOR.PATCH)
  - `1.0.0` - Major release
  - `1.1.0` - Minor release (new features)
  - `1.1.1` - Patch release (bug fixes)

- **BUILD_NUMBER**: Unique integer
  - Must be unique for every release
  - Never reuse a build number
  - Options:
    - Simple incrementing: `100, 101, 102...`
    - Date-based: `260825` (YYMMDD format)
    - Timestamp: `26082501, 26082502...`

- **TYPE**: Release type
  - `review` - Testing/preview builds
  - `prod` - Production releases

- **SUFFIX** (optional):
  - `-storybook` for Storybook releases

### Valid Examples
```bash
1.0.0+100-review           # Portrai review
1.0.0+100-prod             # Portrai production
1.2.3+150-review           # Portrai review (v1.2.3)
2.0.0+200-prod             # Portrai production (v2.0.0)
2.0.0+50-review-storybook  # Storybook review
2.1.0+55-prod-storybook    # Storybook production
```

---

## 🔧 Version Injection

Version and build numbers from your tag are automatically injected into builds:

### Android
- **Command**: `flutter build --build-name=1.0.0 --build-number=100`
- **Result**: 
  - `versionName` in AndroidManifest.xml
  - `versionCode` in AndroidManifest.xml

### iOS
- **Command**: `flutter build --build-name=1.0.0 --build-number=100`
- **Result**:
  - `CFBundleShortVersionString` (display version)
  - `CFBundleVersion` (build number)

### Web
- **Command**: `flutter build web --dart-define=VERSION=1.0.0 --dart-define=BUILD_NUMBER=100`
- **Access**: Via `String.fromEnvironment()` in code

### In Your Code
```dart
// Access version and build number anywhere in your Flutter code
const version = String.fromEnvironment('VERSION', defaultValue: 'unknown');
const buildNumber = String.fromEnvironment('BUILD_NUMBER', defaultValue: '0');

// Display in UI
Text('Version: $version ($buildNumber)')
```

---

## 🚀 Workflow Structure

### Portrai Workflows

**Main Orchestrators:**
- `portrai_preview.yaml` - Coordinates review releases
- `portrai_production.yaml` - Coordinates production releases

**Build Workflows:**
- `_build_android.yaml` - Android APK/AAB builds
- `_build_ios.yaml` - iOS IPA builds
- `_build_web.yaml` - Web builds
- `_deploy_firebase.yaml` - Firebase App Distribution & Hosting deployment
- `_deploy_playstore.yaml` - Google Play Store deployment
- `_deploy_appstore.yaml` - Apple App Store / TestFlight deployment

**Composite Actions:**
- `setup-flutter-module/` - Flutter setup with caching (used by all apps and packages)
- `extract-version-build/` - Version extraction from tag

### Workflow Pipeline

```
Git Tag Push (1.0.0+100-prod)
  ↓
Extract Version Job
  ├─ VERSION = 1.0.0
  └─ BUILD_NUMBER = 100
  ↓
Quality Checks (portrai.yaml workflow)
  ├─ Format check
  ├─ Analysis
  └─ Tests
  ↓
Build Jobs (parallel)
  ├─→ Android ─→ AAB with version
  ├─→ iOS ─────→ IPA with version
  └─→ Web ─────→ Build with version
  ↓
Deploy Jobs (parallel)
  ├─→ Android ─→ Firebase App Distribution
  ├─→ Android ─→ Google Play Store (internal track)
  ├─→ iOS ─────→ Firebase App Distribution
  ├─→ iOS ─────→ App Store Connect (TestFlight)
  └─→ Web ─────→ Firebase Hosting
  ↓
[Production Only] Create GitHub Release
```

---

## 🔐 Required Setup

For detailed setup guides, see the dedicated READMEs:

| What | Guide |
|------|-------|
| Android signing | `app/portrai/android/.signing/README.md` |
| Google Play Store | `app/portrai/android/.playstore/README.md` |
| iOS code signing | `app/portrai/ios/.signing/README.md` |
| App Store Connect / TestFlight | `app/portrai/ios/.appstore/README.md` |
| Firebase App Distribution (mobile) | `app/portrai/.firebase_distribution/README.md` |
| Firebase Hosting (web) | `app/portrai/web/.deploy/README.md` |

### GitHub Secrets — Quick Reference

| Secret | Used for |
|--------|----------|
| `PORTRAI_ANDROID_KEYSTORE_BASE64` | Android signing |
| `PORTRAI_ANDROID_KEYSTORE_PASSWORD` | Android signing |
| `PORTRAI_ANDROID_KEY_ALIAS` | Android signing |
| `PORTRAI_ANDROID_KEY_PASSWORD` | Android signing |
| `PORTRAI_GOOGLE_SERVICES_JSON` | Firebase config for Android (`google-services.json`) |
| `PORTRAI_GOOGLE_SERVICES_PLIST` | Firebase config for iOS (`GoogleService-Info.plist`) |
| `PORTRAI_PLAY_STORE_SERVICE_ACCOUNT_JSON` | Play Store deployment |
| `PORTRAI_PLAY_STORE_PACKAGE_NAME` | Play Store deployment |
| `PORTRAI_FIREBASE_APP_ID_ANDROID` | Firebase App Distribution (Android) |
| `PORTRAI_FIREBASE_APP_ID_IOS` | Firebase App Distribution (iOS) |
| `PORTRAI_FIREBASE_SERVICE_ACCOUNT` | Firebase App Distribution (mobile) |
| `FIREBASE_PROJECT_ID` | Firebase project ID (all Firebase deployments) |
| `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` | Firebase Hosting (web + storybook) |
| `PORTRAI_APP_STORE_CONNECT_API_KEY_ID` | App Store / TestFlight |
| `PORTRAI_APP_STORE_CONNECT_API_ISSUER_ID` | App Store / TestFlight |
| `PORTRAI_APP_STORE_CONNECT_API_KEY` | App Store / TestFlight |
| `PORTRAI_APP_STORE_BUNDLE_ID` | App Store / TestFlight |
| `PORTRAI_IOS_CERTIFICATE_BASE64` | iOS production code signing *(future)* |
| `PORTRAI_IOS_CERTIFICATE_PASSWORD` | iOS production code signing *(future)* |
| `PORTRAI_IOS_PROVISIONING_PROFILE_BASE64` | iOS production code signing *(future)* |

---

## 💡 Best Practices

### Testing Workflow
1. ✅ Always test with **review** builds first
2. ✅ Verify Firebase deployments work
3. ✅ Test on actual devices from Firebase App Distribution
4. ✅ Only create **prod** tags after successful review testing

### Version Management
1. ✅ Follow semantic versioning
2. ✅ Increment build number for EVERY release
3. ✅ Never reuse build numbers (even across review/prod)
4. ✅ Keep build numbers strictly incrementing

### Tag Management
1. ✅ Tags are immutable - don't delete/recreate unless absolutely necessary
2. ✅ Double-check tag format before pushing
3. ✅ Monitor GitHub Actions after pushing tags
4. ✅ Review workflow logs for any issues

---

## 🧪 Testing Store Deployments

Use a low version tag to test end-to-end before a real release:

```bash
git tag 0.0.1+1-prod
git push origin 0.0.1+1-prod
```

Then verify:
- **Play Store** → Play Console → Testing → Internal testing
- **App Store** → App Store Connect → TestFlight (appears within ~10 minutes)
- **Firebase** → Firebase Console → App Distribution
- **Web** → Firebase Hosting → your preview/live channel

---

## 🔍 Working with Tags

### List Tags
```bash
# All tags
git tag

# Portrai production tags
git tag -l "*+*-prod"

# Storybook tags
git tag -l "*+*-storybook"

# All review tags
git tag -l "*+*-review*"

# Tags for specific version
git tag -l "1.0.0+*"
```

### Delete Tags (if needed)
```bash
# Delete locally
git tag -d 1.0.0+100-review

# Delete from remote
git push origin --delete 1.0.0+100-review
```

---

## 📊 Platform-Specific Notes

### Android
- **Review**: Debug APK (unsigned) → Firebase only
- **Production**: 
  - Release AAB for Google Play Store (internal track)
  - Also deployed to Firebase App Distribution
- **Signing**: Configure in `app/portrai/android/app/build.gradle` for production
- **Play Store**: Builds go to internal track first (can promote later)

### iOS
- **Review**: Debug IPA (no code signing required) → Firebase only
- **Production**: 
  - Release IPA → TestFlight (App Store Connect)
  - Also deployed to Firebase App Distribution
- **Signing**: Requires Apple Developer account + code signing setup
- **TestFlight**: Available for testing, submit to App Store manually
- **⚠️ Note**: Production iOS builds need certificates/provisioning profiles

### Web
- **Review**: Profile build → Firebase Hosting preview channel
- **Production**: Release build → Firebase Hosting live channel
- **Access**: Via custom Firebase Hosting domain

---

## 📦 Artifacts

Build artifacts are available in GitHub Actions:

| Platform | Review Build | Production Build | Retention |
|----------|--------------|------------------|-----------|
| Android | APK | AAB | 7 days (review), 30 days (prod) |
| iOS | IPA | IPA | 7 days (review), 30 days (prod) |
| Web | build/ | build/ | 7 days (review), 30 days (prod) |

Download from: Actions → Workflow run → Artifacts section

---

## 🐛 Troubleshooting

### Workflow Not Triggering
- ✅ Check tag format exactly matches pattern
- ✅ Verify tag was pushed to remote: `git push origin <tag>`
- ✅ Check GitHub Actions tab for any runs

### Build Failures
- ✅ Verify Flutter version (3.47.1)
- ✅ Check dependencies are up to date
- ✅ Review build logs in GitHub Actions
- ✅ Run locally: `flutter build` commands

### Deployment Failures
- ✅ Verify all Firebase secrets are configured
- ✅ Check Firebase project permissions
- ✅ Ensure Firebase services are enabled
- ✅ Review Firebase console for errors

### iOS Code Signing
- ✅ Production builds require proper setup
- ✅ Review builds work without signing
- ✅ Consider using Fastlane for complex setups
- ✅ See Flutter iOS deployment guide

---

## 📋 Tag Pattern Summary

| Pattern | Example | App | Build Type | Deploy Target |
|---------|---------|-----|------------|---------------|
| `*+*-review` | `1.0.0+100-review` | Portrai | Debug/Profile | Firebase (testers/preview) |
| `*+*-prod` | `1.0.0+100-prod` | Portrai | Release | Firebase (production/live) + GitHub Release |
| `*+*-review-storybook` | `2.0.0+50-review-storybook` | Storybook | Release | Firebase Hosting (review) |
| `*+*-prod-storybook` | `2.0.0+50-prod-storybook` | Storybook | Release | Firebase Hosting (live) + GitHub Release |

---

## 🎉 You're Ready!

Your CI/CD pipeline is fully configured. To release:

1. **Create a tag**: `git tag 1.0.0+100-review`
2. **Push it**: `git push origin 1.0.0+100-review`
3. **Monitor**: Check GitHub Actions tab
4. **Test**: Download from Firebase App Distribution
5. **Production**: When ready, tag with `-prod`

For questions or issues, check the workflow files in `.github/workflows/`.
