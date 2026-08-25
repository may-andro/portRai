# Test Coverage Setup Guide

## 📊 Overview

The monorepo now has **generic, reusable test coverage collection** enabled for all 13 modules.

## ⚠️ Important: workflow_run Limitation

The coverage report workflow uses `workflow_run` trigger, which **only works from the default branch** (main) due to GitHub Actions security.

**What this means:**
- ✅ After PR #34 is merged, coverage will work automatically on all future PRs
- ❌ In feature branches (like this PR), coverage collection won't trigger automatically
- 🔄 You can manually trigger coverage report using workflow_dispatch after this PR is merged

**For this PR:** Coverage is being collected but not merged. After merge, it will work automatically.

## ✅ Coverage Enabled For

### Flutter Layers (11 modules)
- ✅ cache
- ✅ core  
- ✅ design_system
- ✅ error_reporter
- ✅ feature_flag
- ✅ firebase
- ✅ log_reporter
- ✅ module_injector
- ✅ remote
- ✅ tracking
- ✅ use_case

### Dart Tools (1 module)
- ✅ firestore_export_import

### Apps (1 module)
- ✅ portrai

**Total: 13 modules collecting coverage** 🎉

## 🚀 Features

Each module workflow now:
- ✅ **Collects coverage** during test runs (`--coverage` flag)
- ✅ **Uploads to Codecov** with module-specific flags
- ✅ **Stores artifacts** (7-day retention for downloads)
- ✅ **Contributes** to merged monorepo coverage report

## 📊 Coverage Report Workflow

**File:** `.github/workflows/coverage-report.yaml`

**Features:**
- Downloads coverage from all modules
- Merges into single lcov report
- Uploads to Codecov dashboard
- **Posts PR comment** with coverage summary

**Example PR Comment:**
```markdown
## 📊 Test Coverage Report

**Overall Coverage:** 85.3%

[Coverage Details]
lines......: 85.3% (1234 of 1447 lines)
functions..: 88.2% (234 of 265 functions)  
branches...: 76.5% (156 of 204 branches)

View detailed report on Codecov
```

## 🔧 Setup Required (One-Time)

### 1. Create Codecov Account
1. Go to https://codecov.io
2. Sign in with GitHub
3. Add repository: `may-andro/portRai`
4. Copy the repository token

### 2. Add GitHub Secret
1. Go to: https://github.com/may-andro/portRai/settings/secrets/actions
2. Click **"New repository secret"**
3. **Name:** `CODECOV_TOKEN`
4. **Value:** Your Codecov repository token
5. Click **"Add secret"**

### 3. That's It!
Coverage will automatically:
- ✅ Collect on every PR
- ✅ Upload to Codecov
- ✅ Post summary comment
- ✅ Show trends over time

## 📈 Codecov Dashboard Features

Once set up, you'll see:

- **Coverage Diff** - How PR changes affect coverage
- **Sunburst Chart** - Visual coverage by module
- **Line-by-Line** - Which lines are covered
- **Historical Trends** - Coverage over time
- **Branch Comparison** - Compare coverage across branches

## 🎯 Coverage Strategy

### Per-Module Tracking
Each module has independent coverage:
```
cache:          85% 
core:           92%
design_system:  78%
portrai:        81%
...
```

### Merged Report
All modules combined:
```
Overall Monorepo: 85.3%
```

## 🛠️ Advanced Configuration (Optional)

### Create codecov.yml

Add to repository root for advanced settings:

```yaml
# codecov.yml
coverage:
  status:
    project:
      default:
        target: 80%          # Minimum coverage target
        threshold: 2%        # Allow 2% drop
    patch:
      default:
        target: 80%          # New code must have 80% coverage

comment:
  layout: "reach,diff,flags,tree"
  behavior: default

# Ignore generated files
ignore:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
  - "**/*.mocks.dart"
  - "**/l10n/"

# Module-specific flags
flags:
  cache:
    paths:
      - layer/cache/
  core:
    paths:
      - layer/core/
  design_system:
    paths:
      - layer/design_system/
  portrai:
    paths:
      - app/portrai/lib/
```

### Coverage Gates

Fail CI if coverage drops:
```yaml
coverage:
  status:
    project:
      default:
        target: auto
        threshold: 1%
        if_ci_failed: error
```

## 📊 Example Workflow

Coverage collection happens automatically:

```yaml
# .github/workflows/cache.yaml
jobs:
  analyze_and_test:
    steps:
      - uses: ./.github/actions/flutter-quality-checks
        with:
          module-path: layer/cache
          collect-coverage: 'true'    # ✅ Enabled
          upload-coverage: 'true'     # ✅ Uploads to Codecov
```

## 🎉 Benefits

1. **Visibility** - See coverage on every PR
2. **Accountability** - Track which modules need tests
3. **Trends** - Historical coverage graphs
4. **Quality Gates** - Prevent coverage regressions
5. **Per-Module** - Identify weak areas
6. **Merged View** - Overall monorepo health

## 🔍 Viewing Coverage

### On GitHub
- PR comments show overall coverage
- Click "Details" link to Codecov dashboard

### On Codecov
- https://codecov.io/gh/may-andro/portRai
- View by branch, PR, or commit
- See coverage diff on PRs
- Export reports

### Locally
Coverage artifacts stored in GitHub Actions:
1. Go to workflow run
2. Download coverage artifacts
3. View lcov.info files

## ✅ Checklist

- [x] Coverage enabled for all 13 modules
- [x] Coverage report workflow created
- [x] Composite actions updated
- [ ] **Add CODECOV_TOKEN to GitHub secrets** ← You need to do this
- [ ] **Create Codecov account** ← You need to do this
- [ ] Verify coverage reports on PRs
- [ ] Set coverage targets (optional)

## 🚀 Next Steps

1. **Complete setup** (add Codecov token)
2. **Create PR** to see coverage in action
3. **Review dashboard** to identify low-coverage modules
4. **Write tests** for modules below target
5. **Set quality gates** to maintain coverage

That's it! Your monorepo now has comprehensive test coverage tracking. 🎉
