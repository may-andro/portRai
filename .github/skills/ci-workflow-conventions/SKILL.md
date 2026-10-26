---
description: 'GitHub Actions CI/CD conventions for this repo: one workflow per layer/app package, shared composite actions, and tag-triggered release pipelines. Use when adding a new layer/app package, editing .github/workflows/**, or setting up release/deployment automation.'
---

# CI Workflow Conventions

Verify against `.github/workflows/**` and `.github/actions/**` if anything here seems stale.

## One workflow per package
Every `layer/<name>` package and app has its own `.github/workflows/<name>.yaml`, triggered on
pull requests that touch that package's path (or shared workflow/action files):

```yaml
name: cache

on:
  pull_request:
    paths:
      - 'layer/cache/**'
      - '.github/workflows/cache.yaml'
      - '.github/actions/**'

permissions:
  contents: read
  pull-requests: write

jobs:
  analyze_and_test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Flutter Module
        uses: ./.github/actions/setup-flutter-module
        with:
          module-path: layer/cache
      - name: Quality Checks
        uses: ./.github/actions/flutter-quality-checks
        with:
          module-path: layer/cache
          collect-coverage: 'true'
```

When adding a new layer, copy the simplest existing one (e.g. `cache.yaml`) and adjust
`name:`, the `paths:` filter, and `module-path:`. Don't invent a different job/step structure.

### Variations to apply only when they actually apply
- **`runs-on: macos-latest`** instead of `ubuntu-latest` — only for packages with golden
  (screenshot) tests that need macOS rendering fidelity (e.g. `design_system.yaml`).
- **`test-command: flutter test --dart-define=CI=true`** on the `flutter-quality-checks` step —
  only for packages whose tests need the CI-mode golden comparison flag.
- **A `Generate workspace code` step** (`uses: ./.github/actions/generate-workspace-code`, with
  `package-name: <package>`) — only for packages that rely on `build_runner` codegen (e.g.
  `module_injector` consumers using `@generateConfigurator`, `json_serializable` models). Add it
  right after `Setup Flutter Module` and before `Quality Checks`.
- **`workflow_call:`** under `on:` — add this alongside `pull_request:` only for a package that a
  release or deploy pipeline needs to call as a quality gate (`portrai.yaml` and `functions.yaml`,
  so their pipelines can depend on them via `uses: ./.github/workflows/<name>.yaml`).

## Shared composite actions (`.github/actions/`)
Don't duplicate steps inline — use the existing composite action:

- **`setup-flutter-module`**: installs Flutter (pinned `flutter-version` input, default
  `3.47.4`) + caches + `pub get` for a `module-path`.
- **`setup-dart-module`**: caches + `dart pub get` for a `module-path`, for pure-Dart CLI tools
  (`tool/firestore_export_import`, `tool/portrai_analyzer`). It doesn't install the SDK; those
  workflows run `dart-lang/setup-dart@v1` with `sdk: '3.13.3'` before it.
- **`flutter-quality-checks`** / **`dart-quality-checks`**: `dart format --set-exit-if-changed`,
  `dart analyze --fatal-infos`, run tests (optionally with coverage), and post a coverage
  comment. Parameters: `module-path`, `collect-coverage` (default `'false'`), and for
  `flutter-quality-checks` only, `test-command` (default `flutter test`); `dart-quality-checks`
  always runs `dart test`.
- **`generate-workspace-code`**: runs melos's dependency-aware `gen` script scoped to
  `package-name` (+ `--include-dependencies`), so a package's own codegen step doesn't need a
  hardcoded list of workspace dependencies to also generate for.
- **`extract-version-build`**: parses `version+build` out of a release tag (outputs `version`,
  `build-number`, `version-with-build`).
- **`prepare-service-account`**: decodes and masks base64 credentials (`credentials-base64`), returning a restricted file path. Use `file-path` under the workspace for Docker actions. Only use `expose-json: 'true'` for Hosting actions that require JSON; never pass unmasked decoded credentials through outputs or plaintext action inputs. Always clean up the file.

If a new workflow needs a step that doesn't map to one of these, prefer adding an input to the
existing composite action over writing bespoke inline shell steps in multiple workflows.

The Node tools (`tool/firestore`, `tool/functions`) have no composite action: their workflows set
up Node 22 (plus Java 21 for `tool/firestore`'s rules tests), then run `npm ci` and
`npm run check` in the tool's directory.

## App-level workflows and release pipelines
App workflows (`portrai.yaml`) follow the same per-package pattern but add a `Generate workspace
code` step and inject required secrets (writing `lib/firebase_options.dart` from the
`PORTRAI_FIREBASE_OPTIONS` secret) before running quality checks, plus `workflow_call:` so release
pipelines can reuse them as a gate. `.github/RELEASES.md` documents every release workflow: what it builds and deploys, and the
secrets it reads.

Release/deploy pipelines are separate, tag-triggered workflows (`portrai_preview.yaml`,
`portrai_production.yaml`, `storybook_review.yaml`, `storybook_production.yaml`,
`legal_production.yaml`). The Portrai pipelines follow this job chain:

1. **`extract-version`**: parses the tag (via `extract-version-build`) and generates release notes
   from `git log` since the previous matching tag.
2. **`quality`**: `needs: [extract-version]`, calls the package's own workflow via
   `uses: ./.github/workflows/<package>.yaml` (requires that workflow to declare
   `workflow_call:`).
3. **`build-<platform>`**: `needs: [extract-version, quality]`, calls a reusable
   `_build_android.yaml` / `_build_ios.yaml` / `_build_web.yaml` workflow (note the leading
   underscore — these are non-triggerable "library" workflows, only invoked via `uses:`).
4. **`deploy-<platform>`**: `needs: [build-<platform>, extract-version]` (`deploy-web` needs only
   `build-web`), calls a reusable `_deploy_firebase.yaml` / `_deploy_appstore.yaml` /
   `_deploy_playstore.yaml` workflow.
5. **`create-release`** (`portrai_production.yaml` only): creates the GitHub release after every
   deploy job succeeds.

The other pipelines are shorter:
- **Storybook** (`storybook_review.yaml`, `storybook_production.yaml`, and the PR-triggered
  `storybook_pr.yaml`): `quality` calls `_storybook_quality.yaml`, `build` calls `_build_web.yaml`
  (version from `app/storybook/pubspec.yaml`, no `extract-version` job), `deploy` calls
  `_deploy_firebase.yaml`. `storybook_production.yaml` also calls `_storybook_release_notes.yaml`.
- **Legal pages** (`legal_production.yaml`): `extract-version` (text after `legal-`) → `deploy`
  → `create-release`, with no quality or build job.

Tag naming conventions per pipeline (each pipeline's `on.push.tags` filter):
- App preview build: `*\+*-review` (e.g. `1.0.0+1-review`)
- App production build: `*\+*-prod` (e.g. `1.0.0+1-prod`)
- Storybook: `*\+*-review-storybook` / `*\+*-prod-storybook`
- Legal pages: `legal-*`

Patterns differ per pipeline, so check the workflow's `on.push.tags` filter before assuming one.

Escape literal `+` in GitHub Actions tag filters using single-quoted YAML
strings, e.g. `'*\+*-prod'`. An unescaped `+` is a repetition operator and
`*+*` is invalid.
Git's `git tag -l '*+*-prod'` uses different glob syntax and needs no escaping.

`functions_production.yaml` is the one branch-triggered deploy: it runs on pushes to `develop`
that change `tool/functions`, calls `functions.yaml` as its quality gate and then deploys the
`portrai` functions codebase. Cloud Functions have no build artifact or version tag, so they
skip the extract-version and build jobs.

New reusable build/deploy workflows should be prefixed with `_` and declare `workflow_call:`
inputs/secrets explicitly (no `pull_request:`/`push:` triggers of their own) — they're building
blocks, not standalone pipelines.
