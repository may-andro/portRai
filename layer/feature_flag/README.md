# Feature Flag 🚩

A comprehensive Flutter package for managing feature flags with multi-source support, persistent caching, and Firebase Remote Config integration. Built for production-ready applications with clean architecture principles.

[![CI Status](https://github.com/your-repo/actions/workflows/feature_flag.yaml/badge.svg)](https://github.com/your-repo/actions/workflows/feature_flag.yaml)

## ✨ Features

- **🎯 Runtime Feature Control**: Enable/disable features without app updates
- **🏗️ Multi-Source Architecture**: Seamlessly switch between remote, cache, and build environment sources
- **💾 Persistent Caching**: Features work offline with intelligent cache management and override support
- **🔥 Firebase Integration**: Built-in Firebase Remote Config support
- **🛡️ Type-Safe Implementation**: Sealed exception classes and strong typing throughout
- **💉 Dependency Injection Ready**: Built-in module configurator for service locator integration
- **🧪 Fully Tested**: Comprehensive test coverage with mocked dependencies
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
    │ DataSource │  │   DataSource    │
    └────────────┘  └─────────────────┘
         ├─────────────────┘
         │
    ┌────▼─────────┐
    │ Remote       │ ← Firebase Remote Config
    │ DataSource   │
    └──────────────┘
```

### Data Sources

1. **BuildEnvFeatureFlagDataSource**: Routes to cache or remote based on `BuildEnvironment.isFeatureFlagCached`
2. **CacheFeatureFlagDataSource**: Wraps remote source with persistent SQLite caching + override support
3. **RemoteFeatureFlagDataSource**: Fetches from Firebase Remote Config

### Build Environments

- **Development/Staging** (`isFeatureFlagCached = true`): 
  - Uses cache with override support
  - Local changes persist across restarts
  - Great for testing feature combinations

- **Production** (`isFeatureFlagCached = false`):
  - Fetches from Firebase Remote Config
  - Live control without app updates
  - No local overrides

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

```dart
import 'package:feature_flag/feature_flag.dart';
import 'package:module_injector/module_injector.dart';

// Add to your module configurators
final serviceLocator = ServiceLocator();
final configurator = FeatureFlagModuleConfigurator();

await configurator.registerDependencies(serviceLocator);

// Get the controller
final controller = serviceLocator.get<FeatureFlagController>();

// Initialize (must be called before first use)
await controller.initFeatureFlags();
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
    }
  }
} on EmptyFeatureFlagsException {
  print('No feature flags loaded');
}
```

### Updating Feature Flags (Development/Staging)

```dart
// Update a feature flag for testing
try {
  final updatedFlag = FeatureFlag(
    key: 'new_dashboard',
    isEnabled: true,
    isOverridden: true,  // Mark as override
    remoteValue: false,  // Store original remote value
  );
  await controller.updateFeatureFlag(updatedFlag);
} on FeatureFlagNotFoundException {
  print('Feature flag not found');
} on EmptyFeatureFlagsException {
  print('No flags loaded');
}
```

### Resetting Feature Flags

```dart
// Reset and reload all feature flags (clears cache/overrides)
try {
  await controller.reset();
  print('Feature flags reset successfully');
} on FeatureFlagResetException {
  print('Failed to reset feature flags');
}
```

## 🎯 Key Concepts

### Override System

The package supports a powerful override system for development:

```dart
final flag = FeatureFlag(
  key: 'feature_key',
  isEnabled: true,        // Current value
  isOverridden: true,     // Marked as overridden
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
| `FeatureFlagUpdateException` | Update operation failed | Log and retry |
| `FeatureFlagResetException` | Reset operation failed | Alert user |
| `EmptyFeatureFlagsException` | No flags available | Ensure initialization completed |
| `FeatureFlagNotFoundException(key)` | Specific flag not found | Use default behavior |

### Environment-Based Behavior

The package automatically adapts based on your build environment:

```dart
// In BuildConfig
class BuildEnvironment {
  final bool isFeatureFlagCached;
  // true in dev/staging → cache with overrides
  // false in production → direct Firebase fetch
}
```

**No configuration needed - it just works!**

## 🧪 Testing

The module includes comprehensive test coverage with mocked dependencies.

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

    setUp(() {
      mockDataSource = MockFeatureFlagDataSource();
      controller = FeatureFlagController(mockDataSource);
    });

    test('should initialize feature flags successfully', () async {
      // Arrange
      final mockFlags = [
        const FeatureFlag(key: 'feature1', isEnabled: true),
        const FeatureFlag(key: 'feature2', isEnabled: false),
      ];
      when(() => mockDataSource.initFeatureFlags())
          .thenAnswer((_) async => mockFlags);
      
      // Act
      await controller.initFeatureFlags();
      
      // Assert
      expect(controller.isFeatureEnabled('feature1'), isTrue);
      expect(controller.isFeatureEnabled('feature2'), isFalse);
    });

    test('should throw FeatureFlagNotFoundException for unknown flag', () {
      // Arrange
      when(() => mockDataSource.initFeatureFlags())
          .thenAnswer((_) async => []);
      
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
  
  /// Initialize feature flags from data source
  /// Throws: FeatureFlagInitializationException
  Future<void> initFeatureFlags();
  
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
  
  /// Reset and reinitialize all flags (clears cache/overrides)
  /// Throws: FeatureFlagResetException
  Future<void> reset();
}
```

### FeatureFlag

Data class representing a feature flag:

```dart
class FeatureFlag extends Equatable {
  const FeatureFlag({
    required this.key,
    required this.isEnabled,
    this.isOverridden = false,
    this.remoteValue,
  });
  
  final String key;
  final bool isEnabled;
  final bool isOverridden;    // Manual override in dev/staging
  final bool? remoteValue;    // Original remote value
  
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
  FutureOr<List<FeatureFlag>> initFeatureFlags();
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag);
  FutureOr<void> reset();
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
Initialize early in app lifecycle:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  final serviceLocator = await setupServiceLocator();
  
  // Initialize feature flags BEFORE runApp
  final controller = serviceLocator.get<FeatureFlagController>();
  await controller.initFeatureFlags();
  
  runApp(MyApp());
}
```

### 4. Testing Strategy
Test both enabled and disabled states:

```dart
group('Feature tests', () {
  test('with feature enabled', () {
    // Test new behavior
  });
  
  test('with feature disabled', () {
    // Test fallback behavior
  });
});
```

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
| `equatable` | Value equality for FeatureFlag objects |
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
