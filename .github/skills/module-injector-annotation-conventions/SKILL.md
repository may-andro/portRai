---
description: Use when registering a class for dependency injection, writing a module configurator, or wiring a repository delegation chain in this Flutter workspace, to apply the module_injector package's annotations correctly.
---

# Module Injector Annotation Conventions

This workspace uses the `layer/module_injector` package's build_runner
generator instead of hand-written service-locator registration. Full
reference: `layer/module_injector/README.md`.

## Core annotations

- `@register` — factory registration. Generator reads the unnamed constructor
  and emits `sl.registerFactory<T>(() => T(sl.get(), ...))`.
- `@registerSingleton` — same, but `sl.registerSingleton<T>(...)` (one lazily
  created instance).
- `@Register(as: AbstractType)` / `@RegisterSingleton(as: AbstractType)` —
  registers a concrete class under an abstract type. Only one class should
  use `as:` for a given abstract type.
- `shouldOverride: true` — pass to `@Register`/`@RegisterSingleton` only when
  a binding is legitimately replaced elsewhere (e.g. a `Fake*` in a test
  module). Don't use it to silence "duplicate registration" errors caused by
  a real design mistake.
- `disposeMethodName: 'close'` (singletons only) — generator emits a
  `dispose:` callback invoking that method when the singleton is
  unregistered. Use for anything holding a connection/stream/subscription.
- `@Inject(ConcreteType)` on a constructor parameter — resolves that specific
  concrete type instead of the parameter's abstract-typed default. Required
  whenever a delegation/decorator chain has more than one class implementing
  the same interface.

## `@generateConfigurator`

Every module (layer package or app feature) has one
`<Module>ModuleConfigurator extends SimpleModuleConfigurator` annotated
`@generateConfigurator`. The generator globs every `.dart` file in the same
directory **recursively**, finds all `@register`/`@registerSingleton`
classes, and emits `$register<Module>Dependencies(ServiceLocator sl)`.

```dart
part 'profile_module_configurator.g.dart'; // only if part-based; app features use a sibling .di.g.dart import instead

@generateConfigurator
class ProfileModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerProfileDependencies(sl);
}
```

- Classes prefixed `_` (private) and files ending `.g.dart`/`.di.g.dart` are
  skipped by the generator — never annotate a private class expecting it to
  be picked up.
- `postDependenciesSetup(ServiceLocator sl)` is the place to do registration
  that can't be expressed with annotations alone: registering a route with
  `ModuleRouteController`, or a feature flag definition with
  `AppFeatureFlagDefinitionRegistry` (see `feature-flag-conventions` skill).
- After adding/changing annotated classes, regenerate with the workspace's
  build_runner command (see root `README.md` / CI skill) — don't hand-edit
  `*.g.dart` files.

## Repository chain (decorator) pattern

Used when a repository has multiple backing implementations (cache, demo,
remote) selected at runtime by build config:

```dart
// 1. Cache layer — registered under its own concrete type.
@register
class CacheProfileRepository implements ProfileRepository {
  CacheProfileRepository(this._cache, this._mapper, this._appLocale);
}

// 2. Remote layer — delegates to cache via @Inject.
@register
class RemoteProfileRepository implements ProfileRepository {
  RemoteProfileRepository(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheProfileRepository) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );
}

// 3. Build-config selector — the only one exposed as the abstract type.
@Register(as: ProfileRepository)
class BuildConfigProfileRepository implements ProfileRepository {
  BuildConfigProfileRepository(
    this._buildConfig,
    @Inject(RemoteProfileRepository) this._remoteDelegateRepository,
    @Inject(DemoProfileRepository) this._demoDelegateRepository,
  );
}
```

The rest of the app only ever calls `sl.get<ProfileRepository>()` and
transparently gets whichever concrete chain the build-config selector picks.
Real example: `app/portrai/lib/src/feature/profile/data/repository/`.

## Don't invent

Only the annotations documented above and in
`layer/module_injector/README.md` exist. Don't introduce new annotation
parameters, a `@Lazy` annotation, or manual `sl.registerFactory` calls
outside a `registerDependencies`/`postDependenciesSetup` override — that
defeats the generator and this skill's whole point.

## Related skills

- `flutter-architecture-conventions` — use case / bloc structure that
  consumes these registered dependencies.
- `creating-new-modules` — full new-module scaffolding, including where the
  `@generateConfigurator` class lives.
