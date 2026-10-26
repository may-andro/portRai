---
description: 'Structure, style and content conventions for README.md files in this repo (root workspace, layer packages, apps and tools), plus the content rules that also apply to code comments, so docs stay consistent and factual. Use when writing or editing any README.md under layer/, app/, tool/, or the workspace root, or when writing doc or code comments.'
---

# README Conventions

Every `layer/*` README follows the layer template below, and every `app/*` README follows the
app template. Use the templates for **new** READMEs,
and nudge other existing ones toward this shape when you're already editing them for another
reason — don't do a drive-by rewrite of an unrelated README.

## General style rules
- Describe implemented behavior, configuration, and limitations as factual reference material.
  Do not include implementation progress, PR sequencing, or promises about future work;
  keep those in plans and PR descriptions.
- Plain ATX headings, **no emoji** in headings or bullet points (e.g. `## Features`, not
  `## ✨ Features`).
- Sentence case for headings (`## Getting started` or `## Getting Started` — match whichever the
  sibling READMEs in the same folder use; don't introduce a third variant).
- Fenced code blocks always specify a language (` ```dart `, ` ```bash `, ` ```yaml `).
- Link to sibling docs with relative paths (e.g. `[module_injector](../module_injector/README.md)`).
- Keep a single H1 title matching the package/app name in Title Case (e.g. `# Log Reporter`, not
  the raw package identifier `log_reporter`).

## Content rules for READMEs and code comments
These apply to every README and to doc and code comments in any language.

- **No circumstantial details.** Describe what the code does and why the design holds in
  general, not the story of how it got there. Leave out incidents, debugging sessions, live-run
  numbers, "X was failing so we switched to Y", and dates of decisions; those belong in commit
  messages and PR descriptions.

  ```ts
  // ❌ Wrong
  /** `gemini-3.8-flash` was throttled for minutes, while this model answered every call. */
  // ✅ Correct
  /** The model every function calls. */
  ```
- **Shared code stays generic.** A layer (`layer/*`) or a shared module (such as
  `tool/functions/src/shared/`) never names an app feature, its collections, fields or business
  terms, in its README, comments, examples or tests. Use neutral placeholders such as
  `parents/{parentId}/children`, `items` or `settings`. Feature-specific examples belong in the
  feature's own docs.

  ```dart
  // ❌ Wrong, in layer/firebase
  /// Paths may point at subcollections, such as `users/{uid}/job_openings`.
  // ✅ Correct
  /// Paths may point at subcollections, such as `parents/{parentId}/children`.
  ```

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
