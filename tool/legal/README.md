# Legal Pages – Firebase Hosting

Static HTML pages hosting the **PortRai** app's required legal documents, served via Firebase Hosting. These URLs are referenced in the Google Play Store and Apple App Store listings.

| Page | Live URL |
|---|---|
| Privacy Policy | https://portrai-legal.web.app/privacy-policy |
| Terms & Conditions | https://portrai-legal.web.app/terms |

---

## Structure

```
tool/legal/
├── firebase.json               # Firebase Hosting config (target: "legal")
├── .firebaserc                 # Firebase project: portrai-96f2b
├── README.md
└── public/
    ├── favicon.png             # Copied from app/portrai/web/favicon.png
    ├── icons/
    │   ├── Icon-192.png        # Copied from app/portrai/web/icons/
    │   └── Icon-512.png
    ├── privacy-policy/
    │   └── index.html          # {{VERSION}} placeholder stamped at deploy time
    └── terms/
        └── index.html          # {{VERSION}} placeholder stamped at deploy time
```

---

## First-Time Setup

> Only needed once. Skip if the Firebase site already exists.

1. Open the [Firebase Console](https://console.firebase.google.com/project/portrai-96f2b/hosting) → **Hosting** → **Add another site**.
2. Create a site named exactly **`portrai-legal`** (must match `.firebaserc`).
3. Add the following secret to the GitHub repository (Settings → Secrets → Actions):

   | Secret | Value |
   |---|---|
   | `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` | Firebase service account JSON with Hosting deploy permissions |
   | `FIREBASE_PROJECT_ID` | `portrai-96f2b` |

4. Install the Firebase CLI for local work:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

---

## Release

Legal pages are versioned independently from the app using the tag format:

```
legal-<major>.<minor>.<patch>
```

### When to release

| Change type | Version bump |
|---|---|
| Typo fix, minor wording | `patch` — e.g. `1.0.1` |
| New clause, added section | `minor` — e.g. `1.1.0` |
| Complete rewrite, new data practices | `major` — e.g. `2.0.0` |

### How to release

```bash
# 1. Make your changes to public/privacy-policy/index.html or public/terms/index.html
# 2. Commit and push to main
git add tool/legal/
git commit -m "legal: update privacy policy data retention section"
git push

# 3. Tag the release
git tag legal-1.1.0
git push origin legal-1.1.0
```

The [`legal_production.yaml`](../../.github/workflows/legal_production.yaml) CI workflow triggers automatically and:

1. Extracts the version from the tag (`legal-1.1.0` → `1.1.0`)
2. Stamps `{{VERSION}}` into the `<meta name="version">` tag and footer of every HTML page
3. Deploys to Firebase Hosting (`live` channel, `legal` target)
4. Creates a GitHub Release with a changelog scoped to `tool/legal/` commits

### Local deploy (without CI)

```bash
# Replace {{VERSION}} manually first
VERSION="1.1.0"
find tool/legal/public -name "*.html" -exec sed -i "s/{{VERSION}}/${VERSION}/g" {} +

cd tool/legal
firebase deploy --only hosting:legal
```

> ⚠️ Don't commit the stamped HTML files — `{{VERSION}}` should stay as a placeholder in source.

---

## Editing Content

Edit the HTML files in `public/` directly — no build step required. Key things to keep in sync when updating the policies:

- **Effective date** and **Last updated** fields at the top of each page
- The **data table** in the Privacy Policy (Section 2) if new Firebase services are added
- The **third-party services list** in both pages
