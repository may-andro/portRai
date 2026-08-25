# Test Coverage Setup Guide

## 📊 Overview

The monorepo now has **generic, reusable test coverage collection** that works for all modules (layers, apps, tools).

## ✅ What's Included

### 1. Composite Actions (Generic)
Both `flutter-quality-checks` and `dart-quality-checks` now support:
- ✅ **collect-coverage** - Collect coverage during tests
- ✅ **upload-coverage** - Upload to Codecov (optional)
- ✅ **Artifact upload** - Store coverage files as artifacts

### 2. Coverage Report Workflow
- **File:** `.github/workflows/coverage-report.yaml`
- **Triggers:** On all PRs
- **Features:**
  - Downloads coverage from all modules
  - Merges into single report
  - Uploads to Codecov
  - Posts comment on PR with summary

## 🚀 Usage

### Per Module/Layer (Recommended)

Enable in individual workflows to track module-specific coverage:

```yaml
# Example: .github/workflows/design_system.yaml
jobs:
  analyze_and_test:
    steps:
      - uses: ./.github/actions/flutter-quality-checks
        with:
          module-path: layer/design_system
          collect-coverage: 'true'      # ✅ Enable coverage
          upload-coverage: 'true'        # ✅ Upload to Codecov
```

**Dart modules:**
```yaml
# Example: .github/workflows/cache.yaml
jobs:
  analyze_and_test:
    steps:
      - uses: ./.github/actions/dart-quality-checks
        with:
          module-path: layer/cache
          collect-coverage: 'true'
          upload-coverage: 'true'
```

### App-Level Coverage

```yaml
# Example: .github/workflows/portrai.yaml
jobs:
  analyze_and_test:
    steps:
      - uses: ./.github/actions/flutter-quality-checks
        with:
          module-path: app/portrai
          collect-coverage: 'true'
          upload-coverage: 'true'
```

## 🔧 Setup Required

### 1. Create Codecov Account
1. Go to https://codecov.io
2. Sign in with GitHub
3. Add your repository

### 2. Add Codecov Token
1. Get token from Codecov dashboard
2. Add to GitHub Secrets: `CODECOV_TOKEN`
   - Repository → Settings → Secrets → Actions
   - Name: `CODECOV_TOKEN`
   - Value: Your Codecov token

### 3. Enable Coverage in Workflows

Update each workflow you want coverage for:

```diff
  - uses: ./.github/actions/flutter-quality-checks
    with:
      module-path: layer/your-module
+     collect-coverage: 'true'
+     upload-coverage: 'true'
```

## 📊 Coverage Report Features

### PR Comment
Automatically posts coverage summary on each PR:
```
## 📊 Test Coverage Report

**Overall Coverage:** 85.3%

[Coverage Details]
lines......: 85.3% (1234 of 1447 lines)
functions..: 88.2% (234 of 265 functions)
branches...: 76.5% (156 of 204 branches)

View detailed report on Codecov
```

### Codecov Dashboard
- Line-by-line coverage view
- Coverage diff on PRs
- Historical trends
- Branch comparison
- Sunburst charts

## 🎯 Coverage Strategy

### Recommended Approach: **Per Module**

**Pros:**
- ✅ Track coverage for each layer independently
- ✅ Set different targets per module
- ✅ See which modules need more tests
- ✅ Merged report shows overall coverage

**Enable for:**
- ✅ **All layers** (cache, core, design_system, etc.)
- ✅ **All apps** (portrai, storybook)
- ✅ **Critical modules** (error_reporter, firebase, network)

**Skip for:**
- ❌ Modules with no tests
- ❌ Generated code modules

## 📈 Benefits

1. **Visibility** - See coverage on every PR
2. **Trends** - Track coverage over time
3. **Accountability** - Coverage gates prevent regressions
4. **Modularity** - Each layer's coverage tracked separately
5. **Merged View** - Overall monorepo coverage available

## 🔍 Example Workflow

```yaml
name: my_module

on:
  pull_request:
    paths:
      - 'layer/my_module/**'

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: ./.github/actions/setup-flutter-module
        with:
          module-path: layer/my_module
      
      - uses: ./.github/actions/flutter-quality-checks
        with:
          module-path: layer/my_module
          collect-coverage: 'true'
          upload-coverage: 'true'
```

## 🛠️ Advanced Configuration

### Coverage Thresholds (Codecov YAML)

Create `codecov.yml` in repo root:

```yaml
coverage:
  status:
    project:
      default:
        target: 80%
        threshold: 2%
    patch:
      default:
        target: 80%

comment:
  layout: "reach,diff,flags,tree"
  behavior: default
  
flags:
  layer/cache:
    paths:
      - layer/cache/
  layer/core:
    paths:
      - layer/core/
  app/portrai:
    paths:
      - app/portrai/lib/
```

### Exclude Generated Files

In `codecov.yml`:
```yaml
ignore:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
  - "**/*.mocks.dart"
  - "**/l10n/"
```

## 🚀 Quick Start

1. **Add Codecov token** to GitHub secrets
2. **Update 3-5 critical modules** to enable coverage
3. **Create PR** to see coverage report
4. **Gradually enable** for all modules

That's it! Coverage tracking is now part of your CI/CD pipeline. 🎉
