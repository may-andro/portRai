# Portrai Analyzer

An [`analysis_server_plugin`](https://pub.dev/packages/analysis_server_plugin) plugin with lint
rules that enforce the workspace's import boundaries, described in the
[import boundary conventions](../../.github/skills/import-boundary-conventions/SKILL.md).

## Rules
Both rules are registered as warning rules, so they run without being listed in
`analysis_options.yaml`, and they report at `info` severity.

### `no_cross_module_internal_imports`
Flags an `import` of a `package:<name>/src/...` URI when the importing library belongs to a
different package.

```dart
// Flagged outside the cache package
import 'package:cache/src/db_cache.dart';
```

It does not flag:
- A package importing its own `src/` files, including from its `test/` directory.
- Relative imports and non-`package:` URIs.
- `export` directives.
- Libraries whose own package can't be determined.

### `no_cross_feature_private_imports`
Flags an `import` or `export` of a file whose name starts with `_` and whose URI contains a
`feature/<name>/` segment, when the current library does not belong to that same feature.

```dart
// Flagged outside the experience feature
import 'package:portrai/src/feature/experience/presentation/bloc/_bloc.dart';
```

The feature is identified by the path segment after `feature`, not by the full path, so a test
file under `test/src/feature/experience/` or `test/mock/feature/experience/` counts as part of
the `experience` feature and may import that feature's private barrels.

## Getting Started
The root `analysis_options.yaml` enables the plugin by path:

```yaml
plugins:
  portrai_analyzer:
    path: tool/portrai_analyzer
```

The package is not a member of the root pub workspace and resolves its own dependencies.

## Usage
Run the analyzer from the repository root:

```bash
dart analyze --fatal-infos .
```

IDEs show the diagnostics through the Dart Analysis Server. Restart it after changing the
`plugins` section.

## Configuration
The analysis server's plugin loader requires the plugin's `analysis_server_plugin` version to
satisfy a constraint tied to the Dart SDK version. If `dart analyze` reports "An error occurred
while executing an analyzer plugin" instead of the expected lints:

1. Run `dart pub get` in `tool/portrai_analyzer` to see the required range.
2. Bump `analysis_server_plugin`, `analyzer`, `analyzer_plugin`, and `analyzer_testing` (which is
   coupled to `analyzer`) in `pubspec.yaml` to versions that resolve together.
3. Run the tests below, then `dart analyze` on a file elsewhere in the workspace to confirm the
   plugin loads and its rules fire.

## Testing
The tests use `analyzer_testing` and are not run by CI:

```bash
cd tool/portrai_analyzer
dart pub get
dart test
```
