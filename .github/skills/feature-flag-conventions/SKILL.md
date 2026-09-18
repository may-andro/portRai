---
description: Use when adding, reading, or toggling a feature flag in this Flutter workspace, to follow the app's AppFeatureFlagDefinition + registry pattern instead of calling the feature_flag layer directly.
---

# Feature Flag Conventions

Reference: `layer/feature_flag/README.md` (generic layer API) and
`app/portrai/lib/src/feature/feature_flag/` (this app's wrapper around it).

## Layer vs. app-level types

- `layer/feature_flag` only knows a generic
  `FeatureFlagDefinition(key:, defaultValue:)` and a `FeatureFlagController`
  that resolves each key's value (Firebase Remote Config with a local
  fallback/override system for staging).
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
// app/portrai/lib/src/feature/portfolio/domain/feature_flag/portfolio_feature_flags.dart
abstract final class PortfolioFeatureFlags {
  static const testimonialsSection = AppFeatureFlagDefinition(
    key: 'feature_testimonials_section',
    defaultValue: false,
    displayName: 'Testimonials Section',
    description: 'Enables the testimonials section on portfolio page',
  );

  static const all = [testimonialsSection, /* ...other flags */];
}
```

- Key naming: `feature_<snake_case_name>` (e.g. `feature_experiences_section`).
- Always provide `displayName` and a short `description` — they're shown
  verbatim on the dev-tools flags screen.
- Group every flag owned by a feature into one `all` list on the holder
  class.

## Registering the flag

Register every definition from the owning module's
`postDependenciesSetup` (mirrors how `ModuleRouteController` aggregates
routes — see `creating-new-modules`):

```dart
@override
Future<void> postDependenciesSetup(ServiceLocator sl) async {
  final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
  for (final definition in PortfolioFeatureFlags.all) {
    registry.register(definition);
  }
}
```

`AppFeatureFlagDefinitionRegistry` (`@registerSingleton`) is only consumed
by the dev-tools screen, opened well after every module finishes
registering, so registration order between configurators doesn't matter.
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
has contributed its definitions (see the layer README's "Getting Started"
for the exact call site/order).

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
