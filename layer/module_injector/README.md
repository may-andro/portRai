# Module Injector

A Flutter package that provides a modular dependency injection system with **code generation**,
lifecycle management, and status tracking. Built on top of GetIt, it enables organised dependency
registration through configurable modules and compile-time annotations.

## Features

- **Code Generation** — Annotate classes with `@register` / `@registerSingleton` and let the
  generator wire everything up
- **Modular Architecture** — Organise dependencies into separate modules using `ModuleConfigurator`
- **Lifecycle Management** — Three-phase dependency setup (pre-registration, registration,
  post-registration)
- **Decorator / Chain Support** — Use `@Inject(ConcreteType)` to wire complex repository chains with
  multiple implementations of the same interface
- **Abstract Type Registration** — Use `@Register(as: AbstractType)` to expose a concrete class
  under its interface
- **Override Support** — Use `shouldOverride: true` to replace an existing registration (useful in
  tests)
- **Dispose Callbacks** — Use `disposeMethodName` on `@RegisterSingleton` to auto-generate cleanup
  code
- **Status Tracking** — Real-time injection status updates through streams
- **Service Locator Pattern** — Abstract service locator with GetIt implementation
- **Type Safety** — Full type safety for dependency registration and retrieval

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  module_injector:
    path: layer/module_injector

dev_dependencies:
  build_runner: ^2.5.4
```

## Annotations

### `@register`

Marks a class for automatic **factory** registration. The generator reads the unnamed constructor
and emits `sl.registerFactory<T>(() => T(sl.get(), ...))`.

```dart
@register
class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;
}
```

Generates:

```dart
sl.registerFactory<GetProfileUseCase>(
  () => GetProfileUseCase(sl.get<ProfileRepository>()),
);
```

### `@registerSingleton`

Same as `@register`, but emits `sl.registerSingleton` instead — a single lazily-created instance.

```dart
@registerSingleton
class ProfileCache extends DBCache<ProfileModel> {
  ProfileCache();
}
```

Generates:

```dart
sl.registerSingleton<ProfileCache>(
  () => ProfileCache(),
);
```

### `@Register(as: AbstractType)` / `@RegisterSingleton(as: AbstractType)`

Registers a concrete class under an abstract type. Only one class should use `as:` for a given
abstract type.

```dart
@Register(as: ExperienceRepository)
class BuildConfigExperienceRepositoryImpl implements ExperienceRepository {
  BuildConfigExperienceRepositoryImpl(this._buildConfig, ...);
}
```

Generates:

```dart
sl.registerFactory<ExperienceRepository>(
  () => BuildConfigExperienceRepositoryImpl(
    sl.get<BuildConfig>(),
    ...
  ),
);
```

### `shouldOverride`

Both `@Register` and `@RegisterSingleton` accept `shouldOverride: true`, which passes
`shouldOverride: true` to the underlying `ServiceLocator` call. Use this when a binding may be
legitimately replaced (e.g. in test modules or multi-module setups).

```dart
@Register(as: ProfileRepository, shouldOverride: true)
class FakeProfileRepository implements ProfileRepository {
  ...
}
```

Generates:

```dart
sl.registerFactory<ProfileRepository>
(
() => FakeProfileRepository(),
shouldOverride: true,
);
```

### `disposeMethodName` (singletons only)

`@RegisterSingleton` accepts a `disposeMethodName` string. When set, the generator emits a
`dispose:` callback that calls that method on the instance when it is unregistered.

```dart
@RegisterSingleton(disposeMethodName: 'close')
class DatabaseConnection {
  void close() {
    ...
  }
}
```

Generates:

```dart
sl.registerSingleton<DatabaseConnection>
(
() => DatabaseConnection(),
dispose: (it) => it.close(),
);
```

### `@Inject(ConcreteType)`

Overrides the resolved type for a **constructor parameter**. Use this when a parameter is typed as
an abstract interface but you need a specific concrete implementation injected.

This is essential for **decorator / chain patterns** where multiple classes implement the same
interface.

```dart
@register
class RemoteExperienceRepositoryImpl implements ExperienceRepository {
  RemoteExperienceRepositoryImpl(this._firestoreController,
      this._appLocale,
      @Inject(CacheExperienceRepositoryImpl) this._cacheDelegateRepository,
      this._mapper,
      this._logReporter,);

  final ExperienceRepository _cacheDelegateRepository; // typed as abstract
}
```

Generates:

```dart
sl.registerFactory<RemoteExperienceRepositoryImpl>(
  () => RemoteExperienceRepositoryImpl(
    sl.get<FbFirestoreController>(),
    sl.get<AppLocale>(),
    sl.get<CacheExperienceRepositoryImpl>(), // ← resolved by @Inject
    sl.get<ExperienceMapper>(),
    sl.get<LogReporter>(),
  ),
);
```

### `@generateConfigurator`

Marks a `SimpleModuleConfigurator` subclass for code generation. The generator globs every `.dart`
file in the same directory as the configurator (recursively), scans for `@register` /
`@registerSingleton` classes, and produces a `$register<Module>Dependencies(ServiceLocator sl)`
function.

```dart
part 'profile_module_configurator.g.dart';

@generateConfigurator
class ProfileModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerProfileDependencies(sl);
}
```

## Repository Chain Pattern

A common pattern where multiple repository implementations form a delegation chain (cache →
asset/remote → build-config selector):

```dart
// 1. Cache layer — registered under its own concrete type
@register
class CacheProfileRepository implements ProfileRepository {
  CacheProfileRepository(this._cache, this._mapper, this._appLocale);
}

// 2. Asset/demo layer — delegates to cache via @Inject
@register
class DemoProfileRepository implements ProfileRepository {
  DemoProfileRepository(this._appLocale,
      @Inject(CacheProfileRepository) this._cacheDelegateRepository,
      this._mapper,
      this._logReporter,);
}

// 3. Remote layer — also delegates to cache via @Inject
@register
class RemoteProfileRepository implements ProfileRepository {
  RemoteProfileRepository(this._firestoreController,
      this._appLocale,
      @Inject(CacheProfileRepository) this._cacheDelegateRepository,
      this._mapper,
      this._logReporter,);
}

// 4. Build-config selector — exposed as the abstract type
@Register(as: ProfileRepository)
class BuildConfigProfileRepository implements ProfileRepository {
  BuildConfigProfileRepository(this._buildConfig,
      @Inject(RemoteProfileRepository) this._remoteDelegateRepository,
      @Inject(DemoProfileRepository) this._demoDelegateRepository,);
}
```

The generator produces all four registrations automatically. The rest of the app resolves
`sl.get<ProfileRepository>()` and gets the `BuildConfigProfileRepository` which delegates to the
correct chain based on build environment.

## Core Concepts

### ModuleConfigurator

Abstract base class for defining dependency modules with three lifecycle phases:

- `preDependenciesSetup` — Setup before dependency registration (e.g., initialise Firebase)
- `registerDependencies` — Register your dependencies
- `postDependenciesSetup` — Additional setup after registration (e.g., register routes, restore
  cached state)

### SimpleModuleConfigurator

A convenience base class with no-op default implementations for `preDependenciesSetup` and
`postDependenciesSetup`. Use this when your module only needs `registerDependencies`.

### ServiceLocator

Abstraction layer for dependency registration and retrieval:

```dart
// Factory — new instance each time
sl.registerFactory<ApiClient>(() => ApiClient());

// Singleton — single lazily-created instance
sl.registerSingleton<Database>(
() => Database(),
dispose: (db) => db.close(),
);

// Retrieve
final client = sl.get<ApiClient>();

// Check
if (sl.isRegistered<ApiClient>()) { ... }

// Cleanup
await sl.unregister<ApiClient>();
await sl.reset();
```

#### Shorthand Extensions

```dart
// Instead of sl.registerFactory<T>(...)
sl.factory<T>(() => MyClass());

// Instead of sl.registerSingleton<T>(...)
sl.singleton<T>(() => MyClass());
```

### InjectionStatus

Enum tracking the dependency injection process:

- `start` — Injection process initiated
- `register` — Dependencies being registered
- `postRegister` — Post-registration setup in progress
- `finished` — All dependencies successfully registered

## Usage

### Setting Up the DI Graph

```dart
final controller = ModuleInjectorController();

final stream = controller.setUpDIGraph(
  configurators: [
    AppModuleConfigurator(buildConfig),
    FirebaseModuleConfigurator(...),
    ProfileModuleConfigurator(),
    ExperienceModuleConfigurator(),
  ],
);

await for (final status in stream) {
  if (status == InjectionStatus.finished) {
    // All dependencies are ready
  }
}
```

### Generator Scoping Rules

The generator follows these rules when scanning for annotated classes:

1. **Feature directory scope** — Globs every `.dart` file under the same directory as the
   configurator file (recursive). No import-following needed — simply place annotated classes in the
   same feature folder.
2. **Deterministic output** — Files are processed in alphabetical path order so the generated file
   is stable across machines and runs.
3. **Skips private classes** — Classes starting with `_` are ignored.
4. **Skips generated files** — Files ending in `.g.dart` or `.di.g.dart` are never scanned.

### When to Use Manual Registration

Use annotations for classes with normal constructors where all dependencies come from DI. Keep
manual registration for:

- **Runtime values** — `sl.registerSingleton(() => buildConfig)`
- **Static accessors** — `sl.registerSingleton(() => FirebaseAuth.instance)`
- **Third-party classes** you don't own and can't annotate

### Error Handling

```dart
try {
  await for (final status in controller.setUpDIGraph(configurators: modules)) {
    // Handle status updates
  }
} on PreInjectionException catch (e) {
  // Handle pre-setup errors
} on RegisterInjectionException catch (e) {
  // Handle registration errors
} on PostInjectionException catch (e) {
  // Handle post-setup errors
}
```

## Testing

Mock configurators can be easily created for testing:

```dart
class TestModule extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    sl.registerFactory<ProfileRepository>(
          () => MockProfileRepository(),
      shouldOverride: true,
    );
  }
}
```

## Architecture

- **Controller Layer** — `ModuleInjectorController` orchestrates the injection process
- **Annotation Layer** — `@register`, `@registerSingleton`, `@Inject`, `@generateConfigurator`
- **Generator Layer** — `ModuleInjectorBuilder` produces registration code at build time via
  glob-based discovery
- **Abstraction Layer** — `ServiceLocator` provides a clean interface for DI operations
- **Implementation Layer** — `GetItServiceLocator` implements the actual DI logic using GetIt
- **Configuration Layer** — `ModuleConfigurator` / `SimpleModuleConfigurator` for modular
  organisation
