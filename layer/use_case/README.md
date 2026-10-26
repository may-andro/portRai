# Use Case

A Flutter package with base classes for use cases that return `Either<Failure, Output>`, a global
interceptor hook for observing every use case call, and a code generator that maps annotated
failures to localized messages.

## Features

- Base classes for `Future` and `Stream` use cases, with and without input
- Exceptions thrown by a use case are converted to a typed `Left` through `mapErrorToFailure`
- `UseCaseInterceptor` callbacks for every call, result and error
- `Failure` base types: `BasicFailure`, `UnknownFailure`, `NoFailure`
- `@Localizable` annotation and a `build_runner` builder that generates a `FailureTranslator`
- Re-exports `package:either_dart/either.dart`

## Getting Started

### Installation

The package is a workspace member:

```yaml
dependencies:
  use_case: any
```

```dart
import 'package:use_case/use_case.dart';
```

### Module Configuration

Add `UseCaseModuleConfigurator` to the app's module configurators. It registers
`UseCaseInterceptorController` as a factory.

```dart
final moduleConfigurators = [
  // ...
  UseCaseModuleConfigurator(),
];
```

Register interceptors through the controller:

```dart
serviceLocator.get<UseCaseInterceptorController>().register(LoggingInterceptor());
```

## Usage

### Use Case with Input

Subclasses implement `execute` and `mapErrorToFailure`. Callers invoke the use case with `call`.

```dart
class GetItemFailure extends BasicFailure {
  const GetItemFailure({super.cause});
}

class GetItemUseCase extends BaseUseCase<Item, String, GetItemFailure> {
  GetItemUseCase(this._repository);

  final ItemRepository _repository;

  @override
  Future<Either<GetItemFailure, Item>> execute(String id) async {
    return Right(await _repository.getItem(id));
  }

  @override
  GetItemFailure mapErrorToFailure(Object e, StackTrace st) {
    return GetItemFailure(cause: e);
  }
}

final result = await getItemUseCase('item-1');
result.fold(
  (failure) => print(failure),
  (item) => print(item),
);
```

`execute` returns `FutureOr<Either<F, O>>`, so it may be synchronous. It may also return a `Left`
directly; only thrown errors go through `mapErrorToFailure`.

### Use Case without Input

```dart
class GetItemsUseCase extends BaseNoParamUseCase<List<Item>, UnknownFailure> {
  GetItemsUseCase(this._repository);

  final ItemRepository _repository;

  @override
  Future<Either<UnknownFailure, List<Item>>> execute() async {
    return Right(await _repository.getItems());
  }

  @override
  UnknownFailure mapErrorToFailure(Object e, StackTrace st) {
    return UnknownFailure(cause: e);
  }
}
```

### Stream Use Cases

`BaseStreamUseCase<I, O, F>` and `BaseNoParamStreamUseCase<O, F>` take an `execute` that returns
`Stream<O>`. `call` returns `Stream<Either<F, O>>`: each value is wrapped in `Right`, and each error
is mapped to a `Left` through `mapErrorToFailure` without closing the stream. Note the type
parameter order: the stream base class takes input first (`I, O, F`), while `BaseUseCase` takes
output first (`O, I, F`).

```dart
class WatchItemsUseCase extends BaseStreamUseCase<String, List<Item>, UnknownFailure> {
  WatchItemsUseCase(this._repository);

  final ItemRepository _repository;

  @override
  Stream<List<Item>> execute(String parentId) => _repository.watchItems(parentId);

  @override
  UnknownFailure mapErrorToFailure(Object e, StackTrace st) {
    return UnknownFailure(cause: e);
  }
}
```

### Interceptors

```dart
class LoggingInterceptor implements UseCaseInterceptor {
  @override
  void onCall<Param>(String tag, Param param) => print('call $tag: $param');

  @override
  void onSuccess<Output>(String tag, Output result) => print('result $tag: $result');

  @override
  void onError(String tag, Object error, StackTrace? stackTrace) =>
      print('error $tag: $error');
}
```

- `tag` is `<runtimeType>_<microsecondsSinceEpoch>`, created once per call.
- `param` is the input, or `null` for no-input use cases.
- `onSuccess` receives the returned `Either` (including a `Left` returned by `execute`), and for
  streams each `Right` value.
- `onError` is called when `execute` throws or a stream emits an error.

Interceptors are stored in a static list shared by all use cases, so a registered interceptor
applies to every use case in the process.

### Localized Failures

Annotate failure classes with `@Localizable` and a localization key:

```dart
@Localizable('errorItemNotFound')
class ItemNotFoundFailure extends BasicFailure {
  const ItemNotFoundFailure({super.cause});
}
```

The `use_case|failure_translator` builder has `auto_apply: none`, so enable it in the consuming
package's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      use_case|failure_translator:
        enabled: true
        generate_for:
          - lib/**
```

Running `build_runner` (`melos run gen`) scans `lib/**.dart` and writes
`lib/generated/failure_translator.g.dart` with a `FailureTranslator` class:

- `static String translate(BuildContext context, Failure failure)` returns
  `context.localizations.<key>` for annotated failures, `context.localizations.errorGeneric` for
  `UnknownFailure` and unmatched failures, and `''` for `NoFailure`.
- `static String getFallbackMessage(Failure failure)` returns a readable name derived from the
  class name (for example `Item Not Found`), without needing a `BuildContext`.

The consuming package must provide `context.localizations` with an `errorGeneric` entry and one
entry per annotation key. No file is written when no annotated failures are found.

## API Reference

### Use Case Base Classes

| Class | `call` signature | `execute` to implement |
|-------|------------------|------------------------|
| `BaseUseCase<O, I, F>` | `FutureOr<Either<F, O>> call(I input)` | `FutureOr<Either<F, O>> execute(I input)` |
| `BaseNoParamUseCase<O, F>` | `FutureOr<Either<F, O>> call()` | `FutureOr<Either<F, O>> execute()` |
| `BaseStreamUseCase<I, O, F>` | `Stream<Either<F, O>> call(I input)` | `Stream<O> execute(I input)` |
| `BaseNoParamStreamUseCase<O, F>` | `Stream<Either<F, O>> call()` | `Stream<O> execute()` |

`F` must extend `Failure`. Every class also requires `F mapErrorToFailure(Object e, StackTrace st)`.
`execute` and `mapErrorToFailure` are `@protected`.

### Failures

- `Failure`: abstract base type.
- `BasicFailure`: abstract, extends `Equatable`, with an optional `Object? cause` that is used for
  equality and `toString`.
- `UnknownFailure`: concrete `BasicFailure` with `cause`.
- `NoFailure`: for use cases that do not fail.

### Interceptors

- `UseCaseInterceptor`: `onCall<Param>(String tag, Param param)`,
  `onSuccess<Output>(String tag, Output result)`,
  `onError(String tag, Object error, StackTrace? stackTrace)`.
- `UseCaseInterceptorController`: `register(UseCaseInterceptor interceptor)`.

### Code Generation

- `Localizable(String key)`: annotation read by the `failure_translator` builder.

### Module Configuration

- `UseCaseModuleConfigurator`: registers `UseCaseInterceptorController`.

## Dependencies

| Package | Purpose |
|---------|---------|
| `either_dart` | `Either`, `Left`, `Right` (re-exported) |
| `equatable` | Value equality for `BasicFailure` |
| `meta` | `@protected` |
| `module_injector` | `ModuleConfigurator` and `ServiceLocator` |
| `analyzer`, `build`, `glob`, `source_gen` | The `failure_translator` builder |

## Testing

From the workspace root:

```bash
melos run test --scope=use_case
```

Or from `layer/use_case`:

```bash
flutter test
```

The package does not export test helpers.
