---
description: 'Structure and style conventions for README.md files in this repo (root workspace, layer packages, and apps), so new/edited READMEs stay consistent with each other. Use when writing or editing any README.md under layer/, app/, or the workspace root.'
---

# README Conventions

Existing READMEs under `layer/*` and `app/*` currently drift in heading style, emoji use, and
section order (compare `layer/core/README.md` vs `layer/feature_flag/README.md` vs
`app/portrai/README.md`). Use the templates below for **new** READMEs, and nudge existing ones
toward this shape when you're already editing them for another reason — don't do a drive-by
rewrite of an unrelated README.

## General style rules
- Plain ATX headings, **no emoji** in headings or bullet points (e.g. `## Features`, not
  `## ✨ Features`). Most existing READMEs (`core`, `cache`, `log_reporter`, `use_case`,
  `tracking`, `error_reporter`, `remote`, `design_system`, `firebase`, `module_injector`) already
  follow this — `feature_flag`, the root `README.md`, and `app/portrai/README.md` are the
  emoji-heavy outliers; don't copy their style for new docs.
- Sentence case for headings (`## Getting started` or `## Getting Started` — match whichever the
  sibling READMEs in the same folder use; don't introduce a third variant).
- Fenced code blocks always specify a language (` ```dart `, ` ```bash `, ` ```yaml `).
- Link to sibling docs with relative paths (e.g. `[module_injector](../module_injector/README.md)`).
- Keep a single H1 title matching the package/app name in Title Case (e.g. `# Log Reporter`, not
  the raw package identifier `log_reporter`).

## Layer README template (`layer/<name>/README.md`)

Use this section order; omit a section if genuinely not applicable (e.g. `Platform Support` for a
pure-Dart layer with no platform channels), but don't reorder or rename the sections that do
apply:

```markdown
# <Layer Title>

<1-2 sentence description of what this layer provides and why it exists.>

## Features
- <bullet list of capabilities>

## Getting Started
### Installation
<pubspec dependency snippet>

### Module Configuration
<how to register the layer's ModuleConfigurator, if it has one — see the
creating-new-modules skill>

## Usage
<code examples, simplest first, building up to advanced usage>

## API Reference
<public classes/interfaces consumers use — or call this section "Key Concepts" if it's more
about concepts than a literal API surface; pick one term and use it consistently within the doc>

## Platform Support
<only if the layer has platform-specific behavior>

## Dependencies
<key packages this layer depends on and why>

## Testing
<how to run this layer's tests, e.g. `melos run test --scope=<name>`, and any testing utilities
it exports for consumers (fakes/mocks)>
```

Notes:
- `Getting Started` + `Usage` + `Testing` are mandatory for every layer README.
- Extra layer-specific sections (e.g. `design_system`'s `Components`/`Theming`, `firebase`'s
  `Services`, `remote`'s `Exception Handling`) are fine — insert them between `Usage` and
  `Dependencies`, not before `Getting Started`.

## App README template (`app/<name>/README.md`)

```markdown
# <App Title>

<1-2 sentence description of what the app is.>

## Features
- <bullet list>

## Getting Started
### Prerequisites
### Installation

## Architecture
<brief dependency-flow / layer usage summary, link to the root README's architecture section
for the full picture instead of repeating it>

## Development
### Running the App
### Code Generation
### Testing

## Configuration
<build variants, environment variables, feature flags>

## Deployment
<per-platform build/deploy commands>

## Contributing
<link to the root README's "Contributing" section instead of duplicating the workflow>
```

Don't duplicate the root README's Melos scripts table or contributing workflow — link to it
(`[root README](../../README.md#contributing)`) instead of re-explaining it per app.

## Root workspace README (`README.md`)
The root README is the one exception allowed a broader structure (Table of Contents, full
Architecture/Workspace Structure/Scripts/Contributing sections) since it's the entry point for
the whole monorepo. When adding a new layer or app, update its `Workspace Structure` and any
Melos script tables rather than leaving them stale — don't let per-package READMEs become the
only source of truth for facts the root README also claims to cover.

## When editing an existing README
- If you're touching a README for an unrelated reason (e.g. adding a new API to a layer you're
  also documenting), align the section you're editing with the template above rather than
  introducing yet another heading style — but don't reflow the entire file's headings/emoji in
  the same PR unless the user explicitly asked for a README cleanup.
