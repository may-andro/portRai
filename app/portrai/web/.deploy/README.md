# Firebase Hosting Deployment

Local credentials for deploying the Portrai web app to Firebase Hosting. The `web/.deploy/`
folder is git-ignored (`app/portrai/.gitignore`) except for this README, and no workflow reads
from it: CI gets the same credentials from GitHub secrets.

## Prerequisites

- A service account in the Firebase project `portrai-96f2b` with the Firebase Hosting Admin
  role, and a JSON key saved here as `service-account.json`. This is a different account from
  the App Distribution one in `PORTRAI_FIREBASE_SERVICE_ACCOUNT`.
- The Firebase CLI, for local deploys.

## Hosting Setup

`app/portrai/firebase.json` declares the `portrai` hosting target:

- `public: "build/web"`, the Flutter web build output.
- A rewrite of every path (`**`) to `/index.html`, so the app handles routing.
- `Cache-Control: no-cache` on `index.html` and on `.js`, `.css` and `.wasm` files.

`app/portrai/.firebaserc` sets `portrai-96f2b` as the default project and maps the `portrai`
target to the `portrai-96f2b` Hosting site.

## Usage

### CI

The release workflows build with `.github/workflows/_build_web.yaml` and deploy with the
`deploy-web` job of `.github/workflows/_deploy_firebase.yaml`:

| Workflow | Tag | Build | Hosting channel |
|----------|-----|-------|-----------------|
| `portrai_preview.yaml` | `*+*-review` | `flutter build web --profile`, `build_env=staging` | `preview` |
| `portrai_production.yaml` | `*+*-prod` | `flutter build web --release`, `build_env=prod` | `live` |

The build job writes `lib/firebase_options.dart`, generates the SQLite web assets, builds with the
tag's `--build-name` and `--build-number`, and replaces the `MAPS_API_KEY` placeholder in
`build/web/index.html`. The deploy job downloads that artifact into `app/portrai/build/web`,
decodes the service account with `.github/actions/prepare-service-account`, and deploys with
`FirebaseExtended/action-hosting-deploy@v0` to the `portrai` target.

### Local deploy

Set `FIREBASE_APP_CHECK_WEB_SITE_KEY` and `MAPS_API_KEY_WEB` in `app/portrai/.env.production`, or
export them, then run from the workspace root:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/app/portrai/web/.deploy/service-account.json"
melos run deploy_portrai
```

`deploy_portrai` builds the release web app with `build_env=prod`, checks the SQLite assets,
injects the Maps key into `index.html` and runs `firebase deploy --only hosting:portrai`, which
deploys to the live channel. Running `firebase login` instead of setting
`GOOGLE_APPLICATION_CREDENTIALS` also works.

## Configuration

GitHub Actions secrets and variables used by the web release jobs:

| Name | Kind | Used for |
|------|------|----------|
| `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` | Secret | Base64-encoded service account JSON for the deploy |
| `FIREBASE_PROJECT_ID` | Secret | `projectId` for the deploy (`portrai-96f2b`) |
| `PORTRAI_FIREBASE_OPTIONS` | Secret | Contents of `lib/firebase_options.dart` for the build |
| `MAPS_API_KEY_WEB` | Secret | Maps key injected into `index.html` |
| `FIREBASE_APP_CHECK_WEB_SITE_KEY` | Variable | App Check site key passed as a `--dart-define` |

The Storybook workflows (`storybook_pr.yaml`, `storybook_review.yaml`,
`storybook_production.yaml`) use the same `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` and
`FIREBASE_PROJECT_ID` secrets for the `storybook` target.

To set the service account secret, run from this folder:

```bash
base64 -i service-account.json | gh secret set FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT
```

## Troubleshooting

- `Firebase web builds require app-check-site-key.`: the `FIREBASE_APP_CHECK_WEB_SITE_KEY`
  repository variable is not set.
- `Maps API key placeholder was not replaced in index.html`: `MAPS_API_KEY_WEB` is set, but
  `web/index.html` no longer contains the `key=MAPS_API_KEY"` placeholder.
- `Service-account credentials must be valid JSON.` or
  `Expected service-account JSON with a private key.`: `FIREBASE_WEB_HOSTING_SERVICE_ACCOUNT` is
  not the base64 of a service account JSON key.
