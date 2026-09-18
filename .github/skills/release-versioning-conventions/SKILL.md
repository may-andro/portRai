---
description: Use when cutting a release, tagging a build, or bumping the app version in this Flutter workspace, to follow the tag-naming convention the release workflows key off of.
---

# Release & Versioning Conventions

Releases are triggered purely by **pushing a git tag** matching one of the
patterns below — there is no manual "run deploy" workflow trigger. See
`ci-workflow-conventions` for the full pipeline chain each of these tags
kicks off (`extract-version → quality → build → deploy`).

## Tag format

`<version>+<build_number>-<suffix>`, e.g. `1.1.4+202530-prod`, parsed by
`.github/actions/extract-version-build/action.yaml`:

| Suffix              | Workflow                                | Purpose                          |
|----------------------|------------------------------------------|-----------------------------------|
| `*+*-review`         | `portrai_preview.yaml`                   | Preview/staging release of the app |
| `*+*-prod`           | `portrai_production.yaml`                | Production release of the app     |
| `*+*-review-storybook` | `storybook_review.yaml`                | Preview release of the storybook app |
| `*+*-prod-storybook`   | `storybook_production.yaml`            | Production release of the storybook app |
| `legal-*`            | `legal_production.yaml`                  | Legal/static pages release (no version+build, just `legal-<version>`) |

- `version` must be a semver-like string (e.g. `1.1.4`) matching the
  `version:` field's first segment in the corresponding `pubspec.yaml`.
- `build_number` is a free-form numeric string (e.g. `202530`) — pick
  whatever monotonically-increasing scheme is agreed for the release,
  it's passed straight through to the platform build tooling as the
  build number.

## Before tagging

Update the `version:` field in the relevant `pubspec.yaml`
(`app/portrai/pubspec.yaml` or `app/storybook/pubspec.yaml`, format
`<version>+<build_number>`, e.g. `1.0.0+1`) to match the tag you're about
to push, then tag the commit that contains that change:

```bash
git tag 1.1.4+202530-prod
git push origin 1.1.4+202530-prod
```

Tagging with a version/build that doesn't match `pubspec.yaml` will make
the built artifact's displayed version inconsistent with what CI reports —
keep them in sync.

## Don't invent

Don't invent a new tag suffix without adding a matching
`on: push: tags:` workflow first — an unrecognized suffix simply won't
trigger anything. Don't assume a `CHANGELOG.md` or automated version-bump
tool exists — there is none in this repo today; version bumps are a
manual `pubspec.yaml` edit.

## Related skills

- `ci-workflow-conventions` — the full extract → quality → build → deploy
  pipeline these tags trigger, and the composite actions involved.
