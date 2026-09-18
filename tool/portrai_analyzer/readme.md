# portrai_analyzer

Custom [`analysis_server_plugin`](https://pub.dev/packages/analysis_server_plugin)
lint rules for the `portrai` workspace.

## Rules

* `no_cross_module_internal_imports` — forbids importing another package's
  `lib/src/**` implementation files (e.g. `import 'package:cache/src/db_cache.dart';`
  from outside the `cache` package). Only a package's public API (its
  top-level `lib/*.dart` exports) should be imported by other packages.
* `no_cross_feature_private_imports` — forbids importing another app
  feature's private underscore-prefixed barrel files (e.g.
  `import 'package:portrai/src/feature/experience/presentation/bloc/_bloc.dart';`
  from outside the `experience` feature). Only a feature's public,
  non-underscore barrel should be imported by other features.

## Usage

The plugin is enabled for the whole workspace via the root
`analysis_options.yaml`:

```yaml
plugins:
  portrai_analyzer:
    path: tool/portrai_analyzer
```

Restart the Dart Analysis Server (or your IDE) after changing the `plugins`
section, and run `flutter analyze` / `dart analyze` to see the rule applied
from the command line.

## Development

Run the plugin's own tests with:

```sh
cd tool/portrai_analyzer
dart pub get
dart test
```

### Keeping the plugin loadable

The Dart SDK's analysis server plugin loader requires this package's pinned
`analysis_server_plugin`/`analyzer`/`analyzer_plugin` versions to satisfy its
own internal constraint on `analysis_server_plugin` (this moves with the Dart
SDK version). If `dart analyze`/`flutter analyze` reports "An error occurred
while executing an analyzer plugin" instead of the expected lints, run
`dart pub get` inside `tool/portrai_analyzer` to see the exact required
range, bump `analysis_server_plugin`/`analyzer`/`analyzer_plugin` (and
`analyzer_testing`, which is coupled to `analyzer`) to versions that resolve
together, then re-run `dart test` here and `dart analyze` on a sample file
elsewhere in the workspace to confirm the plugin loads and its rules fire.
