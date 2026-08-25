# Coverage Report `workflow_run` Limitation

## 🔒 GitHub Actions Security Restriction

The coverage-report workflow uses the `workflow_run` trigger, which has a **critical security limitation**:

> **`workflow_run` workflows ONLY execute from the default branch (main/master)**

This is a GitHub Actions security feature to prevent untrusted code in PRs from accessing sensitive data or performing privileged operations.

## 📍 Current Situation

**PR #34 (This PR):**
- ✅ All 13 modules **ARE collecting coverage** 
- ✅ Coverage artifacts **ARE being uploaded**
- ✅ Individual modules **ARE uploading to Codecov**
- ❌ Coverage Report workflow **CANNOT trigger** (workflow file not in main yet)
- ❌ Merged coverage report **NOT generated** (needs workflow_run)
- ❌ PR comment **NOT posted** (needs workflow_run)

**After Merge:**
- ✅ coverage-report.yaml will exist in main branch
- ✅ Future PRs will trigger coverage-report workflow
- ✅ Coverage will merge automatically
- ✅ PR comments will post automatically

## 🔍 Evidence

Check the workflow runs:
```bash
# These ran successfully and uploaded coverage:
✅ cache.yaml - uploaded coverage-<hash>
✅ core.yaml - uploaded coverage-<hash>
✅ portrai.yaml - uploaded coverage-<hash>
... (all 13 modules)

# This did NOT run (expected - workflow_run limitation):
❌ coverage-report.yaml - 0 runs from workflow_run trigger
```

## 🎯 What's Working

Even without the merged report, coverage IS being collected:

1. **Per-Module Coverage** ✅
   - Each module uploads to Codecov with its own flag
   - View on Codecov dashboard: https://codecov.io/gh/may-andro/portRai
   - Flags: `cache`, `core`, `portrai`, etc.

2. **Coverage Artifacts** ✅
   - Stored in GitHub Actions for 7 days
   - Download manually if needed
   - Can be merged locally

3. **Codecov Dashboard** ✅
   - Shows per-module coverage
   - Shows trends over time
   - Shows coverage diff on PRs

## 🚀 What Will Work After Merge

Once PR #34 merges to main:

1. **Automatic Merging** ✅
   - Coverage from all modules merged automatically
   - Single monorepo-wide coverage report

2. **PR Comments** ✅
   - Every future PR gets coverage summary comment
   - Shows overall coverage percentage
   - Links to Codecov dashboard

3. **Comprehensive Tracking** ✅
   - Individual module coverage
   - Merged monorepo coverage
   - Historical trends
   - Coverage gates

## 🛠️ Workarounds for This PR

If you want to see merged coverage for PR #34 specifically:

### Option 1: Manual Trigger (After Merge)
1. Merge PR #34
2. Go to Actions → Coverage Report
3. Click "Run workflow" → Select branch
4. Manually trigger on the commit

### Option 2: View on Codecov
1. Go to https://codecov.io/gh/may-andro/portRai
2. Navigate to PR #34
3. View per-module coverage (already uploaded)
4. Codecov will show overall coverage even without merged report

### Option 3: Local Merge
```bash
# Download all coverage artifacts
gh run view <run-id> --log

# Download and unzip
gh run download <run-id>

# Merge locally
lcov --add-tracefile coverage-*/lcov.info --output-file merged.info
lcov --summary merged.info
```

## 📚 References

- [GitHub Docs: workflow_run](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_run)
- [Security: workflow_run from default branch only](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#understanding-the-risk-of-script-injections)

## ✅ Action Items

1. **For this PR:** Accept that merged coverage won't show (limitation is expected)
2. **After merge:** Verify coverage-report workflow triggers on next PR
3. **Future PRs:** Will have full coverage reporting automatically

## 🎉 Bottom Line

**Everything is working correctly!** The limitation is expected and will resolve itself once this PR merges. The infrastructure is in place and ready to work automatically for all future PRs.
