# Feature Flag 🚩

A Flutter package for managing feature flags with automatic remote/local
resolution, persistent caching with developer overrides, and Firebase Remote
Config integration. Designed to be embedded by multiple apps in the same
workspace, each with its own isolated flag cache.

## ✨ Features

- **🎯 Runtime Feature Control**: Enable/disable features without app updates
- **🔍 Automatic Source Detection**: Each flag key is resolved against Firebase Remote Config at runtime - no need to declare upfront whether a flag is "local" or "remote"
- **💾 Persistent Caching**: Features work offline with intelligent cache management and developer override support
- **🏢 Multi-App Isolation**: Each host app gets its own cache namespace via `appId`, so multiple apps in the same workspace never collide on the same flag key
- **🔥 Firebase Integration**: Built-in Firebase Remote Config support
- **🛡️ Type-Safe Implementation**: Sealed exception classes and strong typing throughout
- **💉 Dependency Injection Ready**: Built-in module configurator for service locator integration
- **🌍 Cross-Platform**: Works on Android, iOS, macOS, and Web platforms

## 📦 Architecture

The package uses a layered data source architecture:

```
┌─────────────────────────────────┐
│   FeatureFlagController         │ ← Main API
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│ BuildEnvFeatureFlagDataSource   │ ← Routes based on environment
└────────┬──────────────┬─────────┘
         │              │
    ┌────▼───────┐  ┌──▼──────────────┐
    │   Cache    │  │     Remote      │
    │ DataSource │─▶│   DataSource    │
    └────────────┘  └────────┬────────┘
                              │
                     ┌────────▼────────┐
                     │ Firebase Remote │
                     │     Config      │
                     └─────────────────┘
```

### Data Sources

1. **BuildEnvFeatureFlagDataSource**: Routes to cache or remote based on `BuildEnvironment.isFeatureFlagCached`
2. **CacheFeatureFlagDataSource**: Wraps the remote source with persistent SQLite caching + developer override support
3. **RemoteFeatureFlagDataSource**: Resolves each flag key against Firebase Remote Config, falling back to the caller-supplied default when the key doesn't exist remotely

### Build Environments

- **Staging** (`isFeatureFlagCached = true`):
  - Uses cache with override support
  - Local overrides persist across restarts
  - Great for testing feature combinations

- **Production** (`isFeatureFlagCached = false`):
  - Talks to `RemoteFeatureFlagDataSource` directly, bypassing the cache
  - No local overrides, no persistence - every resolution is fresh
  - Local-only flags (no remote key) are frozen at their default value

## 🎯 Key Concept: Automatic Remote/Local Resolution

Unlike a design where each flag must declare `source: local` or `source:
remote` up front, this package resolves that per key, at runtime, against
whatever currently exists in Firebase Remote Config:

- **Key exists in Firebase Remote Config** → the flag is "remote": its value
  always reflects the current remote value (`hasRemoteSource: true`,
  `remoteValue` populated).
- **Key doesn't exist in Firebase Remote Config** → the flag is "local": it
  falls back to the `FeatureFlagDefinition.defaultValue` the caller supplied,
  persisted so it's stable across restarts (`hasRemoteSource: false`).

This means the same `FeatureFlagDefinition` can transparently "graduate" from
local-only to remote-controlled the moment someone adds the matching key to
the Firebase console - no app code changes required.

## 🚀 Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```yaml
dependencies:
  feature_flag: any
```

```dart
import 'package:feature_flag/feature_flag.dart';
```

### Setup with Module Configuration

`FeatureFlagModuleConfigurator` requires an `appId` - it namespaces the
underlying SQLite cache so multiple apps embedding this package in the same
workspace (e.g. `portrai`, `storybook`) never collide on the same flag key.

```dart
import 'package:feature_flag/feature_flag.dart';

final moduleConfigurators = [
  // ...
  FeatureFlagModuleConfigurator(appId: 'portrai'),
];
```

Unlike most module configurators, this one does **not** call
`FeatureFlagController.initFeatureFlags` for you: the full catalog of flag
keys is only known by the host app's own features, not by this generic
layer. Call it explicitly once every feature has had a chance to contribute
its definitions - typically right after your app's module-configurator
initialization phase completes (mirroring how a route registry is only read
once every feature has registered its routes):

```dart
final controller = serviceLocator.get<FeatureFlagController>();

await controller.initFeatureFlags(const [
  FeatureFlagDefinition(key: 'new_dashboard', defaultValue: false),
  FeatureFlagDefinition(key: 'feature_language_selector', defaultValue: false),
]);
```

## 📖 Usage

### Basic Feature Check

```dart
class DashboardPage extends StatelessWidget {
  final FeatureFlagController controller;

  const DashboardPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    try {
      final isNewDashboardEnabled = controller.isFeatureEnabled('new_dashboard');

      if (isNewDashboardEnabled) {
        return NewDashboardWidget();
      }
      return LegacyDashboardWidget();
    } on FeatureFlagNotFoundException {
      // Handle case where flag doesn't exist
      return LegacyDashboardWidget();
    } on EmptyFeatureFlagsException {
      // Handle case where no flags are loaded
      return LoadingWidget();
    }
  }
}
```

### Working with All Feature Flags

```dart
// Get all feature flags
try {
  final allFlags = controller.getAllFeatureFlags();
  for (final flag in allFlags) {
    print('${flag.key}: ${flag.isEnabled}');
    if (flag.isOverridden) {
      print('  ↳ Overridden (remote: ${flag.remoteValue})');
    } else if (!flag.hasRemoteSource) {
      print('  ↳ Local only (no matching remote key)');
    }
  }
} on EmptyFeatureFlagsException {
  print('No feature flags loaded');
}
```

### Updating Feature Flags (Staging Only)

```dart
// Update a feature flag for testing
try {
  final updatedFlag = FeatureFlag(
    key: 'new_dashboard',
    isEnabled: true,
    isOverridden: true,   // Mark as override
    hasRemoteSource: true,
    remoteValue: false,   // Original remote value preserved
  );
  await controller.updateFeatureFlag(updatedFlag);
} on FeatureFlagNotFoundException {
  print('Feature flag not found');
} on EmptyFeatureFlagsException {
  print('No flags loaded');
}
```

In production (`isFeatureFlagCached == false`), `updateFeatureFlag` and
`reset` are no-ops on the data source side - there's no cache to write to,
so calls silently have no lasting effect.

### Resetting Feature Flags

```dart
// Reset and reload all feature flags (clears cache/overrides), re-resolving
// against the same definitions passed to initFeatureFlags
try {
  await controller.reset();
  print('Feature flags reset successfully');
} on FeatureFlagResetException {
  print('Failed to reset feature flags');
}
```

## 🎯 Key Concepts

### FeatureFlagDefinition

The generic seed the host app supplies - just a key and the value to fall
back to when that key doesn't exist remotely. Deliberately minimal: display
metadata (name, description, etc.) is a presentation concern that belongs to
the app embedding this package, not to this module.

```dart
class FeatureFlagDefinition extends Equatable {
  const FeatureFlagDefinition({required this.key, required this.defaultValue});

  final String key;
  final bool defaultValue;
}
```

### Override System

The package supports a powerful override system for development:

```dart
final flag = FeatureFlag(
  key: 'feature_key',
  isEnabled: true,        // Current value
  isOverridden: true,     // Marked as overridden
  hasRemoteSource: true,
  remoteValue: false,     // Original remote value preserved
);
```

**Benefits:**
- 🔍 See what's been changed locally
- 🔄 Easy to reset to remote values
- 🧪 Test feature combinations without affecting remote config

### Exception Handling

The package provides specific exception types for different failure scenarios:

| Exception | When Thrown | Handling |
|-----------|-------------|----------|
| `FeatureFlagInitializationException` | Initialization failed | Retry or use default values |
| `FeatureFlagResetException` | Reset operation failed | Alert user |
| `EmptyFeatureFlagsException` | No flags available | Ensure initialization completed |
| `FeatureFlagNotFoundException(key)` | Specific flag not found | Use default behavior |

### Environment-Based Behavior

The package automatically adapts based on your build environment:

```dart
// In BuildConfig
class BuildEnvironment {
  final bool isFeatureFlagCached;
  // true in staging  → cache with overrides
  // false in production → direct Firebase fetch, no overrides
}
```

**No configuration needed - it just works!**

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Testing with Feature Flags

```dart
import 'package:feature_flag/feature_flag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFeatureFlagDataSource extends Mock implements FeatureFlagDataSource {}

void main() {
  group('FeatureFlagController', () {
    late MockFeatureFlagDataSource mockDataSource;
    late FeatureFlagController controller;

    const definitions = [
      FeatureFlagDefinition(key: 'feature1', defaultValue: false),
      FeatureFlagDefinition(key: 'feature2', defaultValue: false),
    ];

    setUp(() {
      mockDataSource = MockFeatureFlagDataSource();
      controller = FeatureFlagController(mockDataSource);
    });

    test('should initialize feature flags successfully', () async {
      // Arrange
      const mockFlags = [
        FeatureFlag(key: 'feature1', isEnabled: true),
        FeatureFlag(key: 'feature2', isEnabled: false),
      ];
      when(() => mockDataSource.resolveFeatureFlags(definitions))
          .thenAnswer((_) async => mockFlags);

      // Act
      await controller.initFeatureFlags(definitions);

      // Assert
      expect(controller.isFeatureEnabled('feature1'), isTrue);
      expect(controller.isFeatureEnabled('feature2'), isFalse);
    });

    test('should throw FeatureFlagNotFoundException for unknown flag', () async {
      // Arrange
      when(() => mockDataSource.resolveFeatureFlags(const []))
          .thenAnswer((_) async => []);
      await controller.initFeatureFlags(const []);

      // Act & Assert
      expect(
        () => controller.isFeatureEnabled('unknown'),
        throwsA(isA<FeatureFlagNotFoundException>()),
      );
    });
  });
}
```

## 📚 API Reference

### FeatureFlagController

Main controller for managing feature flags:

```dart
class FeatureFlagController {
  FeatureFlagController(FeatureFlagDataSource dataSource);

  /// Resolves every entry in [definitions] (a flag found in the remote
  /// source wins, otherwise its default value is used) and loads the
  /// result into memory. Retains [definitions] internally so reset() can
  /// re-resolve without the caller supplying them again.
  /// Throws: FeatureFlagInitializationException
  Future<void> initFeatureFlags(List<FeatureFlagDefinition> definitions);

  /// Get all feature flags
  /// Throws: EmptyFeatureFlagsException if empty
  List<FeatureFlag> getAllFeatureFlags();

  /// Check if feature is enabled
  /// Throws: FeatureFlagNotFoundException if not found
  ///         EmptyFeatureFlagsException if no flags loaded
  bool isFeatureEnabled(String key);

  /// Update feature flag (persists to cache if available)
  /// Throws: FeatureFlagNotFoundException if not found
  ///         EmptyFeatureFlagsException if no flags loaded
  Future<void> updateFeatureFlag(FeatureFlag featureFlag);

  /// Reset and reinitialize all flags (clears cache/overrides), re-resolving
  /// against the same definitions passed to initFeatureFlags
  /// Throws: FeatureFlagResetException
  Future<void> reset();
}
```

### FeatureFlagDefinition

```dart
class FeatureFlagDefinition extends Equatable {
  const FeatureFlagDefinition({required this.key, required this.defaultValue});

  final String key;
  final bool defaultValue;
}
```

### FeatureFlag

Data class representing a resolved feature flag:

```dart
class FeatureFlag extends Equatable {
  const FeatureFlag({
    required this.key,
    required this.isEnabled,
    this.isOverridden = false,
    this.hasRemoteSource = false,
    this.remoteValue,
  });

  final String key;
  final bool isEnabled;
  final bool isOverridden;     // Manual override in staging
  final bool hasRemoteSource;  // Whether this key currently exists in Firebase Remote Config
  final bool? remoteValue;     // Last known remote value, always null when hasRemoteSource is false

  // JSON serialization support
  factory FeatureFlag.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();

  // Copy with support for immutability
  FeatureFlag copyWith({...});
}
```

### FeatureFlagDataSource

Abstract interface for data sources:

```dart
abstract class FeatureFlagDataSource {
  FutureOr<List<FeatureFlag>> resolveFeatureFlags(
    List<FeatureFlagDefinition> definitions,
  );
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag);
  FutureOr<void> reset();
}
```

### FeatureFlagModuleConfigurator

```dart
class FeatureFlagModuleConfigurator implements ModuleConfigurator {
  /// [appId] namespaces the cached flag overrides so this package can be
  /// embedded in multiple apps without their caches colliding.
  FeatureFlagModuleConfigurator({required String appId});
}
```

## 🎨 Best Practices

### 1. Graceful Degradation
Always provide fallback behavior for missing features:

```dart
bool isFeatureEnabled(String key) {
  try {
    return controller.isFeatureEnabled(key);
  } on FeatureFlagNotFoundException {
    return false; // Default behavior
  } on EmptyFeatureFlagsException {
    return false; // Not initialized yet
  }
}
```

### 2. Feature Flag Naming
Use descriptive, hierarchical names:

✅ **Good:**
- `ui.new_dashboard`
- `feature.analytics.v2`
- `experiment.onboarding_flow_b`

❌ **Bad:**
- `flag1`
- `test`
- `new_feature`

### 3. Initialization
Initialize early in app lifecycle, once every feature has contributed its
`FeatureFlagDefinition`s:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup DI, run every module configurator's registration phase first
  final serviceLocator = await setupServiceLocator();

  // Then initialize feature flags with the aggregated definitions list
  final controller = serviceLocator.get<FeatureFlagController>();
  await controller.initFeatureFlags(allFeatureFlagDefinitions);

  runApp(MyApp());
}
```

### 4. One Cache Per App
Always pass a distinct, stable `appId` per host app
(`FeatureFlagModuleConfigurator(appId: 'portrai')`) - never share an `appId`
between two different apps, even if they happen to use the same flag keys.

### 5. Cleanup Old Flags
Remove feature flags once features are stable:

```dart
// Before: Feature flag check
if (controller.isFeatureEnabled('new_dashboard')) {
  return NewDashboard();
}
return OldDashboard();

// After: Feature is stable, remove flag
return NewDashboard();
```

## 🌐 Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| Android  | ✅      | Full support |
| iOS      | ✅      | Full support |
| Web      | ✅      | Full support |
| macOS    | ✅      | Full support |
| Linux    | ⚠️      | Not tested |
| Windows  | ⚠️      | Not tested |

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `cache` | Caching functionality and SQLite support |
| `core` | Core utilities and build configuration |
| `firebase` | Firebase Remote Config integration |
| `module_injector` | Dependency injection framework |
| `equatable` | Value equality for FeatureFlag/FeatureFlagDefinition objects |
| `json_annotation` | JSON serialization support |

## 🤝 Contributing

This module follows the workspace development patterns:

1. **Tests Required**: All changes must include appropriate tests
2. **Backward Compatibility**: Maintain API compatibility
3. **Code Style**: Follow Dart conventions and workspace style guide
4. **Documentation**: Update README for API changes

### Development Setup

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .
```

## 📄 License

Part of the workspace - see root LICENSE file.

---

**Questions or Issues?** Check the [Contributing Guidelines](../../CONTRIBUTING.md) or open an issue.
