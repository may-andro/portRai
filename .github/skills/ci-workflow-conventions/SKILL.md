---
description: 'GitHub Actions CI/CD conventions for this repo: one workflow per layer/app package, shared composite actions, and tag-triggered release pipelines. Use when adding a new layer/app package, editing .github/workflows/**, or setting up release/deployment automation.'
---

# CI Workflow Conventions

Derived from the actual `.github/workflows/**` and `.github/actions/**` files — verify against
current workflows if this ever seems stale.

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
  release pipeline needs to call as a quality gate (currently only `app/portrai`'s
  `portrai.yaml`, so its release workflows can depend on it via `uses:
  ./.github/workflows/portrai.yaml`).

## Shared composite actions (`.github/actions/`)
Don't duplicate steps inline — use the existing composite action:

- **`setup-flutter-module`**: installs Flutter (pinned version) + caches + `pub get` for a
  `module-path`.
- **`setup-dart-module`**: same, for pure-Dart CLI tools (e.g. `tool/firestore_export_import`).
- **`flutter-quality-checks`** / **`dart-quality-checks`**: `dart format --set-exit-if-changed`,
  `dart analyze --fatal-infos`, run tests (optionally with `--coverage`), and post a coverage
  comment. Parameters: `module-path`, `test-command` (default `flutter test`),
  `collect-coverage`.
- **`generate-workspace-code`**: runs melos's dependency-aware `gen` script scoped to
  `package-name` (+ `--include-dependencies`), so a package's own codegen step doesn't need a
  hardcoded list of workspace dependencies to also generate for.
- **`extract-version-build`**: parses `version+build` out of a release tag.

If a new workflow needs a step that doesn't map to one of these, prefer adding an input to the
existing composite action over writing bespoke inline shell steps in multiple workflows.

## App-level workflows and release pipelines
App workflows (`portrai.yaml`) follow the same per-package pattern but add a `Generate workspace
code` step and inject required secrets (e.g. writing `firebase_options.dart` from a secret) before
running quality checks, plus `workflow_call:` so release pipelines can reuse them as a gate.

Release/deploy pipelines are separate, tag-triggered workflows (e.g. `portrai_preview.yaml`,
`portrai_production.yaml`, `storybook_review.yaml`, `storybook_production.yaml`,
`legal_production.yaml`), each following this job chain:

1. **`extract-version`**: parses the tag (via `extract-version-build`) and generates release notes
   from `git log` since the previous matching tag.
2. **`quality`**: `needs: [extract-version]`, calls the package's own workflow via
   `uses: ./.github/workflows/<package>.yaml` (requires that workflow to declare
   `workflow_call:`).
3. **`build-<platform>`**: `needs: [extract-version, quality]`, calls a reusable
   `_build_android.yaml` / `_build_ios.yaml` / `_build_web.yaml` workflow (note the leading
   underscore — these are non-triggerable "library" workflows, only invoked via `uses:`).
4. **`deploy-<platform>`**: `needs: [build-<platform>, extract-version]`, calls a reusable
   `_deploy_firebase.yaml` / `_deploy_appstore.yaml` / `_deploy_playstore.yaml` workflow.

Tag naming conventions per pipeline (each pipeline's `on.push.tags` filter):
- App preview build: `*+*-review` (e.g. `1.0.0+1-review`)
- App production build: check the specific `on.push.tags` pattern in `<app>_production.yaml`
  before assuming — patterns differ per pipeline (e.g. storybook uses
  `*+*-review-storybook`/`*+*-prod-storybook`, legal pages use `legal-*`).

New reusable build/deploy workflows should be prefixed with `_` and declare `workflow_call:`
inputs/secrets explicitly (no `pull_request:`/`push:` triggers of their own) — they're building
blocks, not standalone pipelines.
