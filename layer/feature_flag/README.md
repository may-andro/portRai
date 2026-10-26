# Feature Flag

A Flutter package that resolves boolean feature flags against Firebase Remote Config, with a
per-app SQLite cache and developer overrides in staging builds.

## Features

- Resolves each flag key against Firebase Remote Config at runtime; a key that does not exist
  remotely falls back to the default value supplied by the host app
- Caches resolved flags and developer overrides in SQLite when
  `BuildEnvironment.isFeatureFlagCached` is `true` (staging builds)
- Reads Remote Config directly, without a cache, when `isFeatureFlagCached` is `false`
  (production builds)
- Namespaces the cache database by `appId`, so several apps on one device never share cached
  flag values
- Typed exceptions through the sealed `FeatureFlagException` hierarchy
- `FeatureFlagModuleConfigurator` for service locator registration

## Getting Started

### Installation

The package is a workspace member:

```yaml
dependencies:
  feature_flag: any
```

```dart
import 'package:feature_flag/feature_flag.dart';
```

### Module Configuration

Add `FeatureFlagModuleConfigurator` with an `appId`. The `appId` names the cache database
(`<appId>_feature_flag_db`).

```dart
final moduleConfigurators = [
  // ...
  FeatureFlagModuleConfigurator(appId: 'example_app'),
];
```

The configurator registers `FeatureFlagCache`, the `FeatureFlagDataSource` chain and
`FeatureFlagController` as singletons. It resolves `FbRemoteConfigController` (from the
`firebase` layer) and `BuildConfig` (from the `core` layer) from the service locator, so those
must be registered as well.

The configurator does not call `FeatureFlagController.initFeatureFlags`, because the list of flag
keys belongs to the host app. Call it once all flag definitions are known, for example after the
module configurators have finished registering:

```dart
final controller = serviceLocator.get<FeatureFlagController>();

await controller.initFeatureFlags(const [
  FeatureFlagDefinition(key: 'feature_example', defaultValue: false),
  FeatureFlagDefinition(key: 'feature_other', defaultValue: true),
]);
```

## Usage

### Checking a Flag

```dart
bool isEnabled(FeatureFlagController controller, String key) {
  try {
    return controller.isFeatureEnabled(key);
  } on FeatureFlagNotFoundException {
    return false; // key was not part of the definitions
  } on EmptyFeatureFlagsException {
    return false; // initFeatureFlags has not loaded any flags
  }
}
```

### Listing All Flags

```dart
try {
  for (final flag in controller.getAllFeatureFlags()) {
    if (flag.isOverridden) {
      // overridden locally; flag.remoteValue holds the remote value, if any
    } else if (!flag.hasRemoteSource) {
      // key is not in Remote Config; flag.isEnabled is the default value
    }
  }
} on EmptyFeatureFlagsException {
  // no flags loaded
}
```

### Overriding a Flag

```dart
final flag = controller
    .getAllFeatureFlags()
    .firstWhere((f) => f.key == 'feature_example');

await controller.updateFeatureFlag(
  flag.copyWith(isEnabled: !flag.isEnabled, isOverridden: true),
);
```

`updateFeatureFlag` replaces the flag in the controller's in-memory map and passes it to the data
source. With the cache enabled, a flag with `isOverridden: true` is stored as an override and
survives restarts. Without the cache, the data source ignores the update, so the change lasts only
until the next `initFeatureFlags` or `reset`.

### Resetting Flags

```dart
try {
  await controller.reset();
} on FeatureFlagResetException {
  // reset or re-initialization failed
}
```

`reset` clears the in-memory flags, deletes all cached flags (including overrides) when the cache
is enabled, and calls `initFeatureFlags` again with the definitions from the previous call.

## API Reference

### Data Source Chain

```text
FeatureFlagController
        |
BuildEnvFeatureFlagDataSource   (picks a delegate from BuildEnvironment.isFeatureFlagCached)
        |                 \
CacheFeatureFlagDataSource  \
        |                    \
RemoteFeatureFlagDataSource <-'
        |
FbRemoteConfigController
```

- `BuildEnvFeatureFlagDataSource` delegates to the cache data source when
  `BuildEnvironment.isFeatureFlagCached` is `true` (only `BuildEnvironment.staging`), otherwise to
  the remote data source.
- `RemoteFeatureFlagDataSource` reads `FbRemoteConfigController.getAllConfigsValue()`. A key found
  there becomes a flag with `hasRemoteSource: true` and `remoteValue` set to the remote boolean; a
  missing key becomes a flag with `isEnabled` set to `FeatureFlagDefinition.defaultValue`. Its
  `updateFeatureFlag` and `reset` do nothing.
- `CacheFeatureFlagDataSource` wraps the remote data source and merges each resolved flag with the
  cached one:
  - a cached override wins, with `hasRemoteSource` and `remoteValue` refreshed from the remote
    result;
  - otherwise a flag with a remote source takes the remote value;
  - otherwise (a local-only flag) the cached value is kept, and the default is used only when
    nothing is cached.

These data source classes and `FeatureFlagCache` are internal; only the classes below are exported.

### Remote and Local Flags

A flag is not declared as remote or local. The same `FeatureFlagDefinition` resolves to a remote
flag once its key is added to Remote Config, and to its default value while the key is absent.

### FeatureFlagController

| Member | Description | Throws |
|--------|-------------|--------|
| `FeatureFlagController(FeatureFlagDataSource dataSource)` | Constructor. | |
| `Future<void> initFeatureFlags(List<FeatureFlagDefinition> definitions)` | Resolves `definitions` through the data source, loads them into memory and keeps `definitions` for `reset`. | `FeatureFlagInitializationException` |
| `List<FeatureFlag> getAllFeatureFlags()` | Returns all loaded flags. | `EmptyFeatureFlagsException` |
| `bool isFeatureEnabled(String key)` | Returns `isEnabled` for `key`. | `EmptyFeatureFlagsException`, `FeatureFlagNotFoundException` |
| `Future<void> updateFeatureFlag(FeatureFlag flag)` | Replaces a loaded flag and passes it to the data source. | `EmptyFeatureFlagsException`, `FeatureFlagNotFoundException` |
| `Future<void> reset()` | Clears flags, resets the data source and re-initializes. | `FeatureFlagResetException` |

### FeatureFlagDefinition

```dart
const FeatureFlagDefinition({required String key, required bool defaultValue});
```

The key to resolve and the value to use when the key is not in Remote Config. Extends `Equatable`.

### FeatureFlag

```dart
const FeatureFlag({
  required String key,
  required bool isEnabled,
  bool isOverridden = false,
  bool hasRemoteSource = false,
  bool? remoteValue,
});
```

- `isOverridden`: the value was set by a developer override (cached builds only).
- `hasRemoteSource`: the key exists in Remote Config.
- `remoteValue`: the last known remote value; `null` when `hasRemoteSource` is `false`.

Extends `Equatable` and provides `copyWith`, `fromJson` and `toJson` (generated with
`json_serializable` into `feature_flag.g.dart`).

### Exceptions

All extend the sealed `FeatureFlagException`, which implements `AppException` from the `core`
layer.

| Exception | Thrown by |
|-----------|-----------|
| `FeatureFlagInitializationException` | `initFeatureFlags`, when the data source throws |
| `FeatureFlagResetException` | `reset`, when resetting or re-initializing throws |
| `EmptyFeatureFlagsException` | `getAllFeatureFlags`, `isFeatureEnabled`, `updateFeatureFlag`, when no flags are loaded |
| `FeatureFlagNotFoundException` | `isFeatureEnabled`, `updateFeatureFlag`, when the key is not loaded |
| `FeatureFlagUpdateException` | Not thrown by this package |

### FeatureFlagModuleConfigurator

```dart
FeatureFlagModuleConfigurator({required String appId});
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `cache` | `DBCache` base class for the SQLite flag cache |
| `core` | `BuildConfig` / `BuildEnvironment` and `AppException` |
| `firebase` | `FbRemoteConfigController` for Remote Config values |
| `module_injector` | `ModuleConfigurator` and `ServiceLocator` |
| `equatable` | Value equality for `FeatureFlag` and `FeatureFlagDefinition` |
| `json_annotation` | JSON serialization annotations for `FeatureFlag` |

## Testing

From the workspace root:

```bash
melos run test --scope=feature_flag
```

Or from `layer/feature_flag`:

```bash
flutter test
```

The tests use `mocktail` with mocks in `test/mock/`. The package does not export test helpers.
