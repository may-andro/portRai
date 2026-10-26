# Legal Pages

Static HTML pages with the PortRai app's Privacy Policy and Terms & Conditions, served by
Firebase Hosting from the `portrai-legal` site.

| Page | Source | URL |
|---|---|---|
| Privacy Policy | `public/privacy-policy/index.html` | https://portrai-legal.web.app/privacy-policy |
| Terms & Conditions | `public/terms/index.html` | https://portrai-legal.web.app/terms |

## Features
- Plain HTML and inline CSS with no build step; `firebase.json` serves `public/` with
  `cleanUrls`, so pages load without the `.html` suffix.
- Every response carries the `X-Frame-Options: SAMEORIGIN` and `X-Content-Type-Options: nosniff`
  headers.
- Each page has a `<meta name="version">` tag and a footer version that hold a `{{VERSION}}`
  placeholder, stamped at release time.
- The footers link the two pages to each other.

## Structure

```text
tool/legal/
├── firebase.json        # Hosting config: target "legal", public dir, clean URLs, headers
├── .firebaserc          # Default project portrai-96f2b; maps target "legal" to site portrai-legal
└── public/
    ├── favicon.png
    ├── icons/
    │   ├── Icon-192.png # Apple touch icon
    │   └── Icon-512.png
    ├── privacy-policy/
    │   └── index.html
    └── terms/
        └── index.html
```

## Getting Started

### Prerequisites
- A Firebase Hosting site named `portrai-legal` in the `portrai-96f2b` project. The name must
  match the target mapping in `.firebaserc`.
- The Firebase CLI, signed in to an account with Hosting deploy access:

  ```bash
  npm install -g firebase-tools
  firebase login
  ```

### CI Secrets
The release workflow reads these GitHub Actions secrets:

| Secret | Value |
|---|---|
| `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` | Base64-encoded service account JSON with Hosting deploy permissions |
| `FIREBASE_PROJECT_ID` | `portrai-96f2b` |

## Usage

### Editing Content
Edit the HTML files in `public/` directly. Keep `{{VERSION}}` as a placeholder in source. When
changing a policy, also update:

- The **Effective date** and **Last updated** values at the top of the page.
- The data table in Privacy Policy section 2, Data We Collect.
- The third-party services lists: Privacy Policy section 4 and Terms & Conditions section 5.

### Release
Pushing a tag that matches `legal-*` runs
[`legal_production.yaml`](../../.github/workflows/legal_production.yaml):

```bash
git tag legal-1.1.0
git push origin legal-1.1.0
```

The workflow:

1. Takes the version from the tag (`legal-1.1.0` becomes `1.1.0`).
2. Replaces `{{VERSION}}` in every HTML file under `public/`.
3. Deploys `tool/legal` to the `live` channel of the `legal` hosting target.
4. Creates a GitHub Release whose changelog lists commits touching `tool/legal/` since the
   previous `legal-*` tag.

### Local Deploy
The `deploy_legal` Melos script deploys the `legal` target from this folder:

```bash
melos run deploy_legal
```

It does not stamp the version, so the pages show `{{VERSION}}`. To deploy a stamped build,
replace the placeholder first (GNU `sed` syntax, as in the workflow; on macOS use `sed -i ''`),
then restore the sources after deploying:

```bash
VERSION="1.1.0"
find tool/legal/public -name "*.html" -exec sed -i "s/{{VERSION}}/${VERSION}/g" {} +
melos run deploy_legal
git checkout -- tool/legal/public
```
