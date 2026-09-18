---
description: 'Branch naming, PR title, and PR description conventions for this repo. Use when creating a branch, opening/preparing a PR, or writing a PR title/description.'
---

# Branch & PR Conventions

Derived from actual merged PR history (`gh pr list --state merged`), not assumption. Verify
against recent merged PRs if these ever seem stale.

## Base branch
Branches are created off `develop` and PRs target `develop` (not `main`).

## Branch naming
Pattern: `<type>/<kebab-case-description>` — short, descriptive, no issue numbers embedded.

Types actually used, in order of frequency:

- `app/<feature-name>` — a feature/module scoped to the `app` (e.g. `app/portfolio`, `app/settings-locale`, `app/feature-flags`).
- `feature/<description>` — shared layer work, tooling, or cross-cutting features not tied to one app screen (e.g. `feature/layer-tracking`, `feature/force-update`, `feature/modernize-ci-cd-pipeline`).
- `fix/<description>` — bug fixes (e.g. `fix/app-infrastructure-and-external-handler`).
- `chore/<description>` — maintenance, deps, CI tweaks (e.g. `chore/update-dependencies`, `chore/update-flutter-3.47.4`).
- `docs/<description>` — documentation-only changes (e.g. `docs/comprehensive-readme-update`).

Use `app/` only for work under an application module/feature; use `feature/` for shared
`layer/*` packages or repo-wide tooling. Don't invent other prefixes (no `feat/`, `bugfix/`,
`hotfix/`, etc.).

## PR title
Follow Conventional Commits: `<type>(<optional-scope>): <description>`

- `<type>` matches the branch type mapped to a conventional-commit type: `app/`→`feat`,
  `feature/`→`feat`, `fix/`→`fix`, `chore/`→`chore`, `docs/`→`docs`. Use `refactor` when the
  change is a pure refactor with no behavior change, regardless of branch prefix.
- `<optional-scope>` is `(app)` for app-module features and `(layer)` for shared layer work,
  e.g. `feat(app): add portfolio dashboard`, `feat(layer): add use_case layer`. Omit the scope
  when the change doesn't cleanly fit one (e.g. `fix: align splash screen colors and add unit
  tests`, `chore: update CI to Flutter 3.47.4`).
- Description is lowercase, imperative mood, no trailing period.

Examples from history:
```
feat(app): add portfolio dashboard
feat(layer): add use_case layer
fix: add missing app infrastructure and external_app_handler module
chore: update dependencies to latest versions
docs: Add comprehensive README documentation for workspace, apps, and layers
```

The PR title becomes the squash-merge commit message, so it must stand alone as a good commit
subject line.

## PR description
A checkbox-style template exists at
[`.github/pull_request_template.md`](../../pull_request_template.md) and is auto-inserted by
GitHub. In practice, recent merged PRs (#36, #38) do **not** fill in that checkbox template —
they replace it with a lighter free-form structure:

```markdown
## Summary
<1-3 sentences: what this PR does and why>

## Changes
- <bullet list of concrete changes, grouped by module/package when relevant>

## Testing
- <what tests were added/run>

## Validation
- <commands run and their result, e.g. `melos run analyze`, `melos run test`, `melos run format_check`>
```

Use this Summary/Changes/Testing/Validation structure by default. Only use the full checkbox
template from `pull_request_template.md` if the user explicitly asks for it. Keep `Closes #<n>`
in the Summary section when the PR resolves an issue.
