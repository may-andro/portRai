# Log Reporter

A `LogReporter` interface with `debug` and `error` methods. The registered instance writes each
message to the console through the `logger` package and to the Firebase Crashlytics log.

## Features
- `LogReporter` interface with `debug()` and `error()`, each taking an optional tag, error
  object and stack trace.
- Console output through `logger` (`Logger.d` for debug, `Logger.e` for error), including the
  error object and stack trace.
- Crashlytics log lines through the `firebase` layer's `FbCrashlyticsController.logMessage`.
  Each line holds the tagged message and, when a stack trace is given, its top eight frames;
  Crashlytics uploads the log with the next crash or non-fatal report.

## Getting Started
### Installation

```yaml
dependencies:
  log_reporter: any
```

```dart
import 'package:log_reporter/log_reporter.dart';
```

### Module Configuration
`LogReporterModuleConfigurator` has no constructor parameters.

```dart
final configurators = <ModuleConfigurator>[
  FirebaseModuleConfigurator(/* ... */),
  LogReporterModuleConfigurator(),
];
```

`registerDependencies` registers a `Logger` and a `LogReporter` singleton. It reads
`FbCrashlyticsController` from [firebase](../firebase/README.md) while registering, so the
Firebase configurator must come earlier in the list. `postDependenciesSetup` logs one debug
message.

## Usage

```dart
final logReporter = serviceLocator.get<LogReporter>();

logReporter.debug('Loading items', tag: 'ItemRepository');

try {
  await loadItems();
} catch (error, stackTrace) {
  logReporter.error(
    'Failed to load items',
    tag: 'ItemRepository',
    error: error,
    stacktrace: stackTrace,
  );
}
```

## API Reference

### LogReporter

```dart
abstract class LogReporter {
  void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stacktrace,
  });

  void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stacktrace,
  });
}
```

The registered `LogReporter` forwards every call to two internal reporters, Crashlytics first,
then console:

| Destination | Line format | `error` argument |
|-------------|-------------|------------------|
| Console (`logger`) | `<tag>: <message>` | Passed to `logger` with the stack trace |
| Crashlytics log | `[<tag>] <message>`, then up to eight stack frames | Not included |

A `null` tag is printed as `null`. `debug` and `error` produce the same Crashlytics line.

## Platform Support
Console output works on every platform. `FbCrashlyticsController` writes log lines only on
Android and iOS, and only while Crashlytics collection is enabled; elsewhere the Crashlytics
line is dropped.

## Dependencies
- `firebase`: `FbCrashlyticsController` for Crashlytics log lines.
- `logger`: console output.
- `module_injector`: `ModuleConfigurator` and `ServiceLocator`.

## Testing

```bash
melos run test --scope=log_reporter
```

Or, from `layer/log_reporter`:

```bash
flutter test
```

The tests cover the console, Crashlytics and composite reporters with `mocktail`. The package
exports no test fakes; to stub `LogReporter` in a consumer's tests, mock the interface:

```dart
class MockLogReporter extends Mock implements LogReporter {}
```
