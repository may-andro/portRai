# Module Injector

Dependency injection for the workspace. Modules register their dependencies
through `ModuleConfigurator` classes, and a build_runner generator turns
annotated classes into registration code. Registration is backed by GetIt.

## Features

- `ModuleInjectorController` that runs every configurator through three
  phases (pre-setup, registration, post-setup) and reports progress as a
  stream of `InjectionStatus`
- `ServiceLocator` abstraction with factory and lazy singleton registration,
  optional dispose callbacks and override support
- Annotations (`@register`, `@registerSingleton`, `@Inject`,
  `@generateConfigurator`) and a generator that emits a
  `$register<Module>Dependencies` function per module
- `SimpleModuleConfigurator` base class with no-op pre- and post-setup phases
- Typed exceptions (`PreInjectionException`, `RegisterInjectionException`,
  `PostInjectionException`) for configurators to report setup failures

## Getting Started

### Installation

The package is a member of the workspace. Add it, and `build_runner` for code
generation, to a module's `pubspec.yaml`:

```yaml
dependencies:
  module_injector: any

dev_dependencies:
  build_runner: ^2.5.4
```

The generator is declared in this package's `build.yaml` with
`auto_apply: dependents`, so it runs in every package that depends on
`module_injector`. Generate code from the package directory:

```bash
dart run build_runner build
```

`melos run gen` runs the same command in every package that depends on
`build_runner`.

### Module Configuration

Each module has one configurator. Annotate it with `@generateConfigurator`
and call the generated function from `registerDependencies`. The generator
writes a standalone library next to the configurator, named
`<configurator file>.di.g.dart`, which the configurator imports.

```dart
import 'package:example/src/items/items_module_configurator.di.g.dart';
import 'package:module_injector/module_injector.dart';

@generateConfigurator
class ItemsModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerItemsDependencies(sl);
}
```

The function name is `$register` + the class name without
`ModuleConfigurator` + `Dependencies`.

## Usage

### Setting up the dependency graph

```dart
final controller = ModuleInjectorController();

await for (final status in controller.setUpDIGraph(
  configurators: [
    ItemsModuleConfigurator(),
    SettingsModuleConfigurator(),
  ],
)) {
  if (status == InjectionStatus.finished) {
    // All dependencies are registered.
  }
}

final repository = controller.serviceLocator.get<ItemRepository>();
```

`setUpDIGraph` first resets the service locator, then calls
`preDependenciesSetup` on every configurator in list order, then
`registerDependencies` on every configurator, then `postDependenciesSetup` on
every configurator. A configurator can resolve dependencies registered by
configurators earlier in the list.

`ModuleInjectorController()` always returns a controller backed by the same
GetIt instance, so `ModuleInjectorController().serviceLocator` resolves the
same registrations anywhere in the app.

### Registering a class

```dart
@register
class GetItemsUseCase {
  GetItemsUseCase(this._repository);

  final ItemRepository _repository;
}
```

Generates:

```dart
sl.registerFactory<GetItemsUseCase>(
  () => GetItemsUseCase(sl.get<ItemRepository>()),
);
```

### Manual registration

Register by hand, in `registerDependencies` or `postDependenciesSetup`, what
the generator cannot build from a constructor: runtime values, static
instances, and third-party classes that cannot be annotated.

```dart
@override
void registerDependencies(ServiceLocator sl) {
  $registerItemsDependencies(sl);
  sl.registerSingleton<ItemsConfig>(() => config);
}
```

### Error handling

`setUpDIGraph` does not catch errors. An exception thrown by a configurator
ends the stream with that error. Configurators throw the typed exceptions to
signal which phase failed:

```dart
@override
Future<void> postDependenciesSetup(ServiceLocator sl) async {
  final loaded = await sl.get<LoadSettingsUseCase>().call();
  if (!loaded) {
    throw PostInjectionException('Settings could not be loaded', null);
  }
}
```

```dart
try {
  await for (final status in controller.setUpDIGraph(
    configurators: configurators,
  )) {
    // Handle status updates.
  }
} on InjectionException catch (e) {
  // e.message, e.cause
}
```

## Key Concepts

### Annotations

#### `@register`

Shorthand for `Register()`. Marks a class for factory registration under its
own type. The generator reads the unnamed constructor and resolves each
parameter with `sl.get<DeclaredType>()`; named parameters are passed by name.

#### `@registerSingleton`

Shorthand for `RegisterSingleton()`. Same as `@register`, but emits
`sl.registerSingleton`, which creates one instance on first use.

#### `@Register(as: AbstractType)` / `@RegisterSingleton(as: AbstractType)`

Registers the class under `AbstractType` instead of its own type. Only one
class should use `as:` for a given abstract type.

```dart
@Register(as: ItemRepository)
class RemoteItemRepository implements ItemRepository {
  RemoteItemRepository(this._client);

  final ApiClient _client;
}
```

Generates:

```dart
sl.registerFactory<ItemRepository>(
  () => RemoteItemRepository(sl.get<ApiClient>()),
);
```

#### `shouldOverride`

`Register` and `RegisterSingleton` accept `shouldOverride` (default `false`).
When `true`, the generated call passes `shouldOverride: true`, and the service
locator unregisters an existing registration of the same type before
registering the new one. Use it only where a binding is meant to be replaced,
such as a fake in a test module.

```dart
@Register(as: ItemRepository, shouldOverride: true)
class FakeItemRepository implements ItemRepository {
  FakeItemRepository();
}
```

Generates:

```dart
sl.registerFactory<ItemRepository>(
  () => FakeItemRepository(),
  shouldOverride: true,
);
```

#### `disposeMethodName` (singletons only)

`RegisterSingleton` accepts `disposeMethodName`. When set, the generated call
includes a `dispose:` callback that calls that method when the singleton is
unregistered or the locator is reset.

```dart
@RegisterSingleton(disposeMethodName: 'close')
class DatabaseConnection {
  DatabaseConnection();

  void close() {}
}
```

Generates:

```dart
sl.registerSingleton<DatabaseConnection>(
  () => DatabaseConnection(),
  dispose: (it) => it.close(),
);
```

#### `@Inject(ConcreteType)`

Placed on a constructor parameter, resolves `ConcreteType` instead of the
declared parameter type. Needed when several classes implement the same
interface, as in a delegation chain.

```dart
@register
class RemoteItemRepository implements ItemRepository {
  RemoteItemRepository(
    this._client,
    @Inject(CacheItemRepository) this._cacheDelegate,
  );

  final ApiClient _client;
  final ItemRepository _cacheDelegate;
}
```

Generates:

```dart
sl.registerFactory<RemoteItemRepository>(
  () => RemoteItemRepository(
    sl.get<ApiClient>(),
    sl.get<CacheItemRepository>(),
  ),
);
```

#### `@generateConfigurator`

Shorthand for `GenerateConfigurator()`. Marks the module's configurator class
for generation.

### Generator rules

- Scans every `.dart` file under the configurator's directory, including
  subdirectories, for `@register` and `@registerSingleton` classes. Annotated
  classes only need to live in that directory tree; the configurator does not
  have to import them.
- Processes files in path order, so the output is stable.
- Skips private (`_`-prefixed) classes, the configurator file itself, and files
  ending in `.g.dart` or `.di.g.dart`.
- Fails the build if an annotated class has no unnamed constructor.
- Uses the first `@generateConfigurator` class in a file.
- Emits an empty function when no annotated classes are found.
- Adds imports for parameter types that are classes; for other parameter
  types, such as function types, it logs a warning and adds no import.

### Repository chain pattern

Several implementations of one interface can form a delegation chain. Each
link is registered under its own concrete type and receives the next link
through `@Inject`; only the selector is registered under the interface.

```dart
@register
class CacheItemRepository implements ItemRepository {
  CacheItemRepository(this._cache);

  final ItemCache _cache;
}

@register
class RemoteItemRepository implements ItemRepository {
  RemoteItemRepository(
    this._client,
    @Inject(CacheItemRepository) this._cacheDelegate,
  );

  final ApiClient _client;
  final ItemRepository _cacheDelegate;
}

@Register(as: ItemRepository)
class SelectingItemRepository implements ItemRepository {
  SelectingItemRepository(
    this._config,
    @Inject(RemoteItemRepository) this._remoteDelegate,
    @Inject(CacheItemRepository) this._cacheDelegate,
  );

  final ItemsConfig _config;
  final ItemRepository _remoteDelegate;
  final ItemRepository _cacheDelegate;
}
```

Consumers call `sl.get<ItemRepository>()` and receive
`SelectingItemRepository`.

### ModuleConfigurator

```dart
abstract class ModuleConfigurator {
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator);

  FutureOr<void> registerDependencies(ServiceLocator serviceLocator);

  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator);
}
```

- `preDependenciesSetup`: work needed before any registration, such as
  initializing an SDK.
- `registerDependencies`: register the module's dependencies.
- `postDependenciesSetup`: work that needs registered dependencies, such as
  registering routes or loading cached state.

`SimpleModuleConfigurator` implements `ModuleConfigurator` with no-op
`preDependenciesSetup` and `postDependenciesSetup`.

### ServiceLocator

```dart
abstract class ServiceLocator {
  T get<T extends Object>();

  void registerFactory<T extends Object>(
    T Function() factory, {
    bool shouldOverride,
  });

  void registerSingleton<T extends Object>(
    T Function() factory, {
    FutureOr<void> Function(T param)? dispose,
    bool shouldOverride,
  });

  bool isRegistered<T extends Object>();

  Future<void> unregister<T extends Object>();

  Future<void> reset();
}
```

`registerFactory` creates a new instance on every `get`. `registerSingleton`
creates one instance on the first `get` (a GetIt lazy singleton).

The `ServiceLocatorX` extension adds shorthands with the same parameters:
`factory<T>(create, {shouldOverride})` for `registerFactory` and
`singleton<T>(create, {dispose, shouldOverride})` for `registerSingleton`. The
type is inferred from `create` unless given explicitly.

```dart
sl.factory(() => GetItemsUseCase(sl.get()));
sl.singleton<ItemRepository>(() => RemoteItemRepository(sl.get(), sl.get()));
```

### InjectionStatus

Values emitted by `setUpDIGraph`, in order:

- `start`: the locator was reset; pre-setup is about to run.
- `register`: pre-setup finished; registration is about to run.
- `postRegister`: registration finished; post-setup is about to run.
- `finished`: every configurator completed all three phases.

### InjectionException

Sealed base class with `message` and `cause`. Subclasses:
`PreInjectionException`, `RegisterInjectionException` and
`PostInjectionException`, each constructed as `(message, cause)`.

## Dependencies

| Package | Purpose |
|---------|---------|
| `get_it` | Backing service locator |
| `meta` | `@internal` annotation on the GetIt implementation |
| `build` | Builder API for the generator |
| `source_gen` | Annotation lookup in the generator |
| `analyzer` | Reads classes and constructors during generation |
| `glob` | Finds the Dart files under a configurator's directory |

## Testing

```bash
melos run test --scope=module_injector
```

Or from `layer/module_injector`:

```bash
flutter test
```

The package exports no test helpers. A test module can
replace bindings with `shouldOverride: true`:

```dart
class TestItemsModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    sl.registerFactory<ItemRepository>(
      () => FakeItemRepository(),
      shouldOverride: true,
    );
  }
}
```
