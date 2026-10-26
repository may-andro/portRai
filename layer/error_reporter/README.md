# Error Reporter

Reports errors to Firebase Crashlytics or to the log, decides which errors are fatal, and lets
the app register handlers that skip reporting for some errors or react to fatal ones.

## Features
- `ErrorReporter` interface with `init()`, `reportError()` and a `globalErrorHandler` for
  uncaught errors.
- `init()` sets `FlutterError.onError` so framework errors go through the reporter.
- Two implementations, selected by the module configurator: one records errors in Crashlytics
  through the `firebase` layer, the other writes them to `LogReporter`.
- `BlacklistErrorController` collects `BlacklistErrorHandler`s; an error any handler matches is
  not recorded in Crashlytics.
- `FatalErrorController` classifies errors as fatal and runs every registered
  `FatalErrorHandler` when a fatal error is handled.

## Getting Started
### Installation

```yaml
dependencies:
  error_reporter: any
```

```dart
import 'package:error_reporter/error_reporter.dart';
```

### Module Configuration
`ErrorReporterModuleConfigurator` takes one positional `bool isFirebaseEnabled`.

```dart
final configurators = <ModuleConfigurator>[
  FirebaseModuleConfigurator(/* ... */),
  LogReporterModuleConfigurator(),
  ErrorReporterModuleConfigurator(true),
];
```

`registerDependencies` registers `BlacklistErrorController`, `FatalErrorController` and
`ErrorReporter` as singletons. It reads `LogReporter` (from
[log_reporter](../log_reporter/README.md)) and, when `isFirebaseEnabled` is `true`,
`FbCrashlyticsController` (from [firebase](../firebase/README.md)) while registering, so those
configurators must come earlier in the list. `postDependenciesSetup` calls
`ErrorReporter.init()`.

| `isFirebaseEnabled` | Registered `ErrorReporter` |
|---------------------|----------------------------|
| `true`              | Records errors in Crashlytics, honours the blacklist, logs `reportError` calls |
| `false`             | Writes errors to `LogReporter` only; the blacklist is not consulted |

## Usage

### Reporting a caught exception
`reportError` accepts any `AppException` from the `core` layer.

```dart
final errorReporter = serviceLocator.get<ErrorReporter>();

try {
  await loadItems();
} on AppException catch (exception, stackTrace) {
  await errorReporter.reportError(
    exception: exception,
    stackTrace: stackTrace,
    tag: 'items',
  );
}
```

### Handling uncaught errors
`init()` already covers `FlutterError.onError`. Route errors outside the framework to
`globalErrorHandler`:

```dart
PlatformDispatcher.instance.onError = (error, stack) {
  errorReporter.globalErrorHandler(error, stack);
  return true;
};
```

### Skipping errors with a blacklist handler

```dart
class CancelledRequestBlacklistHandler implements BlacklistErrorHandler {
  @override
  bool isBlacklistError(Object error) => error is CancelledRequestException;
}

serviceLocator
    .get<BlacklistErrorController>()
    .register(CancelledRequestBlacklistHandler());
```

### Reacting to fatal errors

```dart
class ExitFatalErrorHandler implements FatalErrorHandler {
  @override
  FutureOr<void> onFatalError(Object error) => exit(1);
}

serviceLocator.get<FatalErrorController>().register(ExitFatalErrorHandler());
```

Register handlers once, for example in an app-level `postDependenciesSetup`. Registering the
same handler instance twice throws an `AppException` (`HandlerRegisteredException`).

## API Reference

### ErrorReporter

```dart
abstract class ErrorReporter {
  Future<void> init();

  Future<void> reportError<T extends AppException>({
    required T exception,
    required StackTrace stackTrace,
    String? tag,
  });

  void Function(Object, StackTrace) get globalErrorHandler;
}
```

Behaviour of the Crashlytics implementation (`isFirebaseEnabled: true`):

- Fatal error: recorded in Crashlytics with `isFatal: true` unless blacklisted, then
  `FatalErrorController.onFatalError` runs.
- Non-fatal error: skipped if blacklisted; otherwise recorded with `reportFlutterError` when it
  came from `FlutterError.onError`, or `reportError` otherwise.
- `reportError` goes through the same steps, then logs the exception with `LogReporter.error`
  and the given `tag`.

Behaviour of the log implementation (`isFirebaseEnabled: false`):

- `reportError` logs the exception with `LogReporter.error` and the given `tag`.
- `globalErrorHandler` and `FlutterError.onError` log the error and stack trace; for a fatal
  error they then run `FatalErrorController.onFatalError`.

### BlacklistErrorController

```dart
class BlacklistErrorController {
  void register(BlacklistErrorHandler handler);
  List<BlacklistErrorHandler> get registeredHandlers;
  bool isBlacklistedError(Object error);
}

abstract class BlacklistErrorHandler {
  bool isBlacklistError(Object error);
}
```

`isBlacklistedError` returns `true` when any registered handler returns `true`.

### FatalErrorController

```dart
class FatalErrorController {
  void register(FatalErrorHandler handler);
  List<FatalErrorHandler> get registeredHandlers;
  bool isFatalError(Object error);
  Future<void> onFatalError(Object error);
}

abstract class FatalErrorHandler {
  FutureOr<void> onFatalError(Object error);
}
```

`isFatalError` returns `true` for any `Error` or `FatalException` (from `core`), except a
`FlutterError` whose message contains `RenderFlex`. `onFatalError` calls each registered
handler in registration order and waits for each one.

## Dependencies
- `core`: `AppException` and `FatalException`.
- `firebase`: `FbCrashlyticsController` for recording errors in Crashlytics.
- `log_reporter`: `LogReporter` for writing errors to the log.
- `module_injector`: `ModuleConfigurator` and `ServiceLocator`.
- `meta`: `@internal` on the reporter implementations.

## Testing

```bash
melos run test --scope=error_reporter
```

Or, from `layer/error_reporter`:

```bash
flutter test
```

The tests cover both controllers and both reporter implementations, using `mocktail`. The
package exports no test fakes.
