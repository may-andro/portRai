---
description: 'Import boundary rules between workspace packages and between app features: never import another package''s lib/src internals, and never import another feature''s private underscore-prefixed barrel files. Use when writing or reviewing any import/export statement across layer/* packages or app/portrai/lib/src/feature/* folders.'
---

# Import Boundary Conventions

Every `layer/*` package and every `app/portrai/lib/src/feature/<name>/` feature exposes its
public API through specific barrel files. Reaching past that public API and importing internal
files directly is not allowed, even though it may compile.

## Rule 1: Never import another package's `lib/src/**`

Each workspace package (`layer/cache`, `layer/core`, `use_case`, etc.) exposes its public API via
one or more top-level files directly under `lib/` (e.g. `layer/cache/lib/cache.dart`). Everything
under that package's `lib/src/` is a private implementation detail.

```dart
// ✅ Correct — import the public barrel
import 'package:cache/cache.dart';

// ❌ Wrong — reaches into another package's internals
import 'package:cache/src/db_cache.dart';
```

A package importing its **own** `lib/src/**` files (including from its own `test/` directory) is
fine — the rule only applies across package boundaries.

## Rule 2: Never import another feature's private barrel files

Within `app/portrai`, each feature under `lib/src/feature/<feature_name>/` organizes its internal
files using barrel files whose name starts with an underscore (`_bloc.dart`, `_widget.dart`,
`_domain.dart`, `_data.dart`, `_presentation.dart`, `_screen.dart`, `_use_case.dart`, etc. — see
the [architecture-conventions skill](../flutter-architecture-conventions/SKILL.md) for the full
feature folder layout). These underscore barrels are private to that feature. A feature exposes
its public API through its own top-level, non-underscore barrel, e.g.
`lib/src/feature/experience/experience.dart`.

```dart
// ✅ Correct — import the feature's public barrel
import 'package:portrai/src/feature/experience/experience.dart';

// ❌ Wrong — reaches into another feature's private barrel
import 'package:portrai/src/feature/experience/presentation/bloc/_bloc.dart';
```

Importing (or exporting) a private barrel from **within the same feature** is exactly how that
feature's own barrels are meant to compose, and is unaffected by this rule.

## Why this matters
Bypassing the public barrel couples callers to another module's/feature's internal file layout,
so an internal refactor (renaming/moving/splitting a file under `src/` or a feature's private
barrels) becomes a breaking change for unrelated code. Always add the type/function you need to
export from the appropriate public barrel instead of importing around it.

## Tooling status
These two rules are implemented as custom analyzer lint rules in
`tool/portrai_analyzer` (`no_cross_module_internal_imports` and
`no_cross_feature_private_imports` — see `tool/portrai_analyzer/lib/src/rules/`) and **are wired
into the root `analysis_options.yaml`** via a `plugins:` section, so `dart analyze`/`flutter
analyze` flag violations automatically (as `info`-level diagnostics — they don't fail
`flutter analyze`/CI on their own, but should still be fixed when seen). If a plugin analyzer
error like "An error occurred while executing an analyzer plugin" shows up instead of the
expected lints, the plugin's pinned `analysis_server_plugin`/`analyzer`/`analyzer_plugin`
versions in `tool/portrai_analyzer/pubspec.yaml` are likely out of sync with the Dart SDK's
plugin loader requirement — bump them to versions that resolve together (`dart pub get` inside
`tool/portrai_analyzer` will report the exact required range) rather than disabling the plugin.

Note the built-in Dart lint `implementation_imports` is also set to `error` in the root
`analysis_options.yaml`, which independently catches basic `package:x/src/...` imports (a subset
of Rule 1) even without the custom plugin enabled.
