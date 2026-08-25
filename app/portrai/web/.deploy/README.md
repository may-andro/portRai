# Firebase Hosting Deployment

Configuration for deploying the Portrai web app to Firebase Hosting.

---

## 🎯 Service Account Setup

### 1. Create Service Account

Go to [Google Cloud Console](https://console.cloud.google.com/) → project `portrai-96f2b`:

1. Navigate to **IAM & Admin** → **Service Accounts**
2. Click **Create Service Account**
   - Name: `github-actions-hosting`
   - Description: `Service account for GitHub Actions Firebase Hosting deployments`
3. Click **Create and Continue**
4. Grant role: **Firebase Hosting Admin**
5. Click **Done**

> ⚠️ Use **Firebase Hosting Admin** — not "Firebase App Distribution Admin" (that's a
> separate role used by `PORTRAI_FIREBASE_SERVICE_ACCOUNT`).

### 2. Download & Store JSON Key

1. Click on the service account you created
2. Go to **Keys** tab → **Add Key** → **Create new key**
3. Choose **JSON** format → **Create**
4. Move the downloaded file to this folder:
   ```bash
   mv ~/Downloads/portrai-96f2b-*.json app/portrai/web/.deploy/service-account.json
   ```
   *(git-ignored — never committed)*

### 3. Encode for CI/CD

```bash
cd app/portrai/web/.deploy
base64 -i service-account.json -o service-account-base64.txt
```

### 4. Add GitHub Secrets

Go to: **Settings** → **Secrets and variables** → **Actions**

```
FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT
→ Contents of service-account-base64.txt

FIREBASE_PROJECT_ID
→ portrai-96f2b
```

---

## 🏗️ How Hosting Is Configured

**`app/portrai/firebase.json`** declares the hosting target:
- `public: "build/web"` — Flutter web build output
- SPA rewrite (`**` → `/index.html`) for Flutter routing
- Cache headers for JS/CSS assets

**`app/portrai/.firebaserc`** maps the `"portrai"` target to the `"portrai-app"` Firebase Hosting site.

> Make sure the `portrai-app` site exists in [Firebase Console](https://console.firebase.google.com/)
> → Hosting → **Add another site**.

---

## 🚀 Local Testing

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Use service account (or run firebase login instead)
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/app/portrai/web/.deploy/service-account.json"

# Build first
cd app/portrai
flutter build web --release

# Deploy to preview channel
firebase hosting:channel:deploy preview --project portrai-96f2b

# Deploy to live channel
firebase deploy --only hosting:portrai --project portrai-96f2b
```

---

## 📚 Resources

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [action-hosting-deploy](https://github.com/FirebaseExtended/action-hosting-deploy)
- Releases guide: `../../../../.github/RELEASES.md`
