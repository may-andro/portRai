---
description: Use when adding, reading, or toggling a feature flag in this Flutter workspace, to follow the app's AppFeatureFlagDefinition + registry pattern instead of calling the feature_flag layer directly.
---

# Feature Flag Conventions

Reference: `layer/feature_flag/README.md` (generic layer API) and
`app/portrai/lib/src/feature/feature_flag/` (this app's wrapper around it).

## Layer vs. app-level types

- `layer/feature_flag` only knows a generic
  `FeatureFlagDefinition(key:, defaultValue:)` and a `FeatureFlagController`
  that resolves each key's value (Firebase Remote Config, falling back to
  `defaultValue`, with a SQLite cache and developer overrides in staging
  builds).
- The app wraps this in its own
  `AppFeatureFlagDefinition(key:, defaultValue:, displayName:, description:)`
  (`app/portrai/lib/src/feature/feature_flag/domain/entity/app_feature_flag_definition.dart`),
  which adds the presentational fields needed by the dev-tools "list all
  flags" screen. Convert to the layer type via `.layerDefinition` only when
  calling into `FeatureFlagController`.

## Declaring a new flag

Each feature that owns a flag declares its own
`<Feature>FeatureFlags` holder class in
`<feature>/domain/feature_flag/<feature>_feature_flags.dart` — the
`feature_flag` module itself never hardcodes any business flag.

```dart
// app/portrai/lib/src/feature/cv_export/domain/feature_flag/cv_export_feature_flags.dart
abstract final class CvExportFeatureFlags {
  static const tailoredCv = AppFeatureFlagDefinition(
    key: 'feature_tailored_cv',
    defaultValue: false,
    displayName: 'Tailored CV',
    description:
        'Lets a CV be tailored for a job: a rewritten summary with the most '
        'relevant projects and skills first',
  );

  static const all = [tailoredCv];
}
```

- Key naming: `feature_<snake_case_name>` (e.g. `feature_tailored_cv`).
- Always provide `displayName` and a short `description` — they're shown
  verbatim on the dev-tools flags screen.
- Group every flag owned by a feature into one `all` list on the holder
  class.

## Registering the flag

Register every definition from the owning module's
`postDependenciesSetup` (mirrors how `ModuleRouteController` aggregates
routes — see `creating-new-modules`), as
`app/portrai/lib/src/feature/cv_export/cv_export_module_configurator.dart`
does:

```dart
@override
void postDependenciesSetup(ServiceLocator sl) {
  sl.get<ModuleRouteController>().register(CvExportModuleRoute.cvExport);
  final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
  for (final definition in CvExportFeatureFlags.all) {
    registry.register(definition);
  }
}
```

`AppFeatureFlagDefinitionRegistry` (`@registerSingleton`, in
`app/portrai/lib/src/feature/feature_flag/domain/registry/`) is read once
every configurator's `postDependenciesSetup` has run — by the
`initFeatureFlags` call at startup and by the dev-tools screen — so
registration order between configurators doesn't matter.
Registering the same `key` twice logs an error and is a no-op for the
second registration — treat that as a bug (duplicate/typo'd key), not a
supported override mechanism.

## Reading a flag's value

Don't call `FeatureFlagController` directly from a bloc/widget for one-off
checks. Use the feature's own use case
(`IsFeatureEnabledUseCase`/`GetAllFeatureFlagsUseCase` in
`app/portrai/lib/src/feature/feature_flag/domain/use_case/`) which follows
the standard `BaseUseCase`/`Failure` pattern from
`flutter-architecture-conventions`.

## Module setup

`FeatureFlagModuleConfigurator(appId: 'portrai')` namespaces the flag cache
per host app. It does **not** auto-call `initFeatureFlags` — the host app
must explicitly call
`FeatureFlagController.initFeatureFlags([...])` once every feature module
has contributed its definitions. In this app that call is `_initFeatureFlags()`
in `app/portrai/lib/src/app/run_app_initialization.dart`, which passes
every registered definition's `.layerDefinition`.

## Don't invent

Don't add a raw `bool` field to a bloc/state for something that should be a
flag — always go through an `AppFeatureFlagDefinition` + the registry so it
shows up in dev tools. Don't skip `displayName`/`description` "to save
time" — they're required, not optional metadata.

## Related skills

- `module-injector-annotation-conventions` — `@registerSingleton` and
  `postDependenciesSetup` mechanics used above.
- `creating-new-modules` — where a feature's `domain/feature_flag/` folder
  fits in the overall feature layout.
