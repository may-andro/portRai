# Firebase App Distribution Configuration

⚠️ **IMPORTANT**: Service account JSON is git-ignored. Never commit credentials!

---

## 🎯 Setup

### 1. Enable Firebase App Distribution

Go to [Firebase Console](https://console.firebase.google.com/):

```bash
# 1. Select your project
# 2. Navigate to: Build → App Distribution
# 3. Click "Get started"
# 4. Register your Android and iOS apps if not already done
```

### 2. Create Service Account

**Option A: Use Existing Play Store Service Account (Recommended)**

If you already have a service account for Play Store, you can reuse it:

```bash
# Copy from Play Store folder
cp android/.playstore/service-account.json .firebase_distribution/
```

**Option B: Create New Service Account**

Go to [Google Cloud Console](https://console.cloud.google.com/):

```bash
# 1. Select your Firebase project
# 2. Navigate to: IAM & Admin → Service Accounts
# 3. Click "Create Service Account"
#    Name: firebase-app-distribution
#    Description: Service account for Firebase App Distribution
# 4. Click "Create and Continue"
# 5. Grant role: "Firebase App Distribution Admin"
# 6. Click "Done"
```

### 3. Download JSON Key

```bash
# 1. Click on the service account
# 2. Go to "Keys" tab
# 3. Click "Add Key" → "Create new key"
# 4. Choose "JSON" format
# 5. Click "Create"
# 6. Move to this folder:
mv ~/Downloads/your-project-*.json service-account.json
```

### 4. Get App IDs

Find your Firebase App IDs:

```bash
# In Firebase Console:
# 1. Go to: Project Settings (gear icon)
# 2. Scroll to "Your apps" section
# 3. Copy App IDs:
#    - Android: 1:123456789:android:abcdef123456
#    - iOS: 1:123456789:ios:abcdef123456
```

Save them for GitHub secrets.

---

## 🔄 How It Works

**Unified approach:** Same folder for local testing and CI/CD!

- **Local**: You store service-account.json here
- **CI/CD**: Workflow uses GitHub secret
- **Release Notes**: Stored in `release-notes.txt`

---

## 📝 Release Notes

Release notes are **automatically generated** from git commits during CI/CD deployment.

### How It Works

When you push a release tag (e.g., `1.2.3+100-review`), the workflow:
1. Finds the previous tag of the same type (review or prod)
2. Extracts all commit messages between tags
3. Formats them into release notes
4. Sends to Firebase App Distribution

**Example auto-generated notes:**
```
Version 1.2.3 (Build 100)

Preview Build - For Testing Only

Changes since 1.2.2+99-review:
• Add dark mode support
• Fix crash on Android 14
• Improve offline sync
• Update dependencies

Triggered by: developer
Commit: a1b2c3d4
```

### Manual Release Notes (Optional)

For **local testing only**, you can manually edit `release-notes.txt`:

```bash
# release-notes.txt (for local CLI testing)
Testing dark mode implementation

Please verify:
• Dark mode toggle works
• Colors are consistent
• Settings persist after restart
```

**Note:** This file is **ignored by CI/CD** - all production releases use auto-generated notes from commits.

### Writing Good Commit Messages

Since release notes are generated from commits, write clear commit messages:

**Good:**
```bash
git commit -m "Add dark mode toggle to settings"
git commit -m "Fix crash when opening profile on Android 14"
git commit -m "Improve sync performance for large datasets"
```

**Bad:**
```bash
git commit -m "update"
git commit -m "fix bug"
git commit -m "wip"
```

**Tips:**
- Start with a verb (Add, Fix, Update, Remove)
- Be specific about what changed
- Keep under 72 characters
- Use present tense

---

## 👥 Tester Groups

Configure tester groups in `tester-groups.txt`:

```bash
# Example tester-groups.txt

# Internal team
team@example.com
dev1@example.com
dev2@example.com

# Beta testers
beta1@example.com
beta2@example.com

# QA team
qa@example.com
```

**Or use Firebase Console:**
1. Go to App Distribution → Testers & Groups
2. Create groups: "Internal", "Beta Testers", "QA"
3. Add emails to each group
4. Use group names in workflows

---

## ⚙️ CI/CD Setup

### Encode Service Account

```bash
cd app/portrai/.firebase_distribution
base64 -i service-account.json -o service-account-base64.txt
```

### GitHub Secrets

Go to: **Settings** → **Secrets and variables** → **Actions**

| Secret | Value | How to get |
|--------|-------|------------|
| `PORTRAI_FIREBASE_SERVICE_ACCOUNT` | Contents of `service-account-base64.txt` | Encode service account JSON with base64 |
| `FIREBASE_PROJECT_ID` | `portrai-96f2b` | From `service-account.json` → `project_id` field |
| `PORTRAI_FIREBASE_APP_ID_ANDROID` | `1:xxx:android:xxx` | Firebase Console → Settings → Android App → App ID |
| `PORTRAI_FIREBASE_APP_ID_IOS` | `1:xxx:ios:xxx` | Firebase Console → Settings → iOS App → App ID |

**Current Project Details:**
- Project ID: `portrai-96f2b`
- Service Account: `firebase-app-distribution@portrai-96f2b.iam.gserviceaccount.com`

---

## 🚀 Local Testing

Test distribution locally using Firebase CLI:

### Install Firebase CLI

```bash
# Install Firebase tools
npm install -g firebase-tools

# Login
firebase login

# Or use service account
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"
```

### Distribute Android APK

```bash
cd app/portrai

# Build APK first
flutter build apk --release

# Distribute
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:123456789:android:abcdef123456 \
  --release-notes-file .firebase_distribution/release-notes.txt \
  --groups "internal-testers" \
  --token "$(gcloud auth print-access-token)"
```

### Distribute iOS IPA

```bash
cd app/portrai

# Build IPA first (requires Mac)
flutter build ipa --release

# Distribute
firebase appdistribution:distribute \
  build/ios/ipa/*.ipa \
  --app 1:123456789:ios:abcdef123456 \
  --release-notes-file .firebase_distribution/release-notes.txt \
  --groups "internal-testers" \
  --token "$(gcloud auth print-access-token)"
```

---

## 🔒 Security & Backup

### Critical Files (MUST Backup!)

```bash
# Backup these files securely
service-account.json    # Cannot be recovered if lost
```

### Backup Strategy

1. **Encrypted Cloud Backup** (Recommended)
   - Use 1Password, LastPass, or similar
   - Store entire `.firebase_distribution` folder (excluding templates)

2. **Secure Location**
   - External encrypted drive
   - Team password manager
   - Secure company vault

3. **Access Control**
   - Only authorized team members
   - Regular access audits

### Best Practices

- Never commit `service-account.json` to git (it's git-ignored)
- Rotate service account keys periodically
- Use least-privilege IAM roles
- Monitor Firebase Console for unauthorized access

---

## 🧪 Testing Checklist

Before pushing to production:

- [ ] Service account JSON placed in folder
- [ ] Base64 encoding verified
- [ ] GitHub secrets configured (4 secrets)
- [ ] Release notes updated
- [ ] Tester groups configured
- [ ] Test local distribution (optional)
- [ ] First deployment successful

---

## 📚 References

- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [Service Account Guide](https://cloud.google.com/iam/docs/service-accounts)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
