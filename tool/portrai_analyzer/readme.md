# portrai_analyzer

Custom [`analysis_server_plugin`](https://pub.dev/packages/analysis_server_plugin)
lint rules for the `portrai` workspace.

## Rules

* `no_cross_module_internal_imports` — forbids importing another package's
  `lib/src/**` implementation files (e.g. `import 'package:cache/src/db_cache.dart';`
  from outside the `cache` package). Only a package's public API (its
  top-level `lib/*.dart` exports) should be imported by other packages.

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
