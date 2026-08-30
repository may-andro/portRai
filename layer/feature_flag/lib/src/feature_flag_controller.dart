import 'dart:async';

import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';
import 'package:feature_flag/src/feature_flag_exception.dart';

/// Controller for managing feature flags throughout the application.
///
/// Example:
/// ```dart
/// await controller.initFeatureFlags([
///   const FeatureFlagDefinition(key: 'new_dashboard', defaultValue: false),
/// ]);
///
/// if (controller.isFeatureEnabled('new_dashboard')) {
///   // Show new dashboard
/// }
///
/// controller.updateFeatureFlag(
///   FeatureFlag(key: 'new_feature', isEnabled: true),
/// );
///
/// await controller.reset();
/// ```
class FeatureFlagController {
  FeatureFlagController(this._dataSource);

  final FeatureFlagDataSource _dataSource;

  final Map<String, FeatureFlag> _featureFlagMap = {};

  // Retained so reset() can re-resolve the same set of flags without the
  // caller having to supply the definitions again.
  List<FeatureFlagDefinition> _definitions = const [];

  /// Resolves every entry in [definitions] (a flag found in the remote
  /// source wins, otherwise its default value is used) and loads the result
  /// into memory.
  Future<void> initFeatureFlags(List<FeatureFlagDefinition> definitions) async {
    try {
      _definitions = definitions;
      _featureFlagMap.clear();
      final featureFlags = await _dataSource.resolveFeatureFlags(definitions);

      for (final flag in featureFlags) {
        _featureFlagMap[flag.key] = flag;
      }
    } catch (e) {
      throw const FeatureFlagInitializationException();
    }
  }

  List<FeatureFlag> getAllFeatureFlags() {
    if (_featureFlagMap.isEmpty) {
      throw const EmptyFeatureFlagsException();
    }

    return _featureFlagMap.values.toList();
  }

  bool isFeatureEnabled(String key) {
    if (_featureFlagMap.isEmpty) {
      throw const EmptyFeatureFlagsException();
    }

    if (_featureFlagMap.containsKey(key) case final bool isAvailable
        when isAvailable) {
      return _featureFlagMap[key]?.isEnabled ?? false;
    }

    throw FeatureFlagNotFoundException(key);
  }

  Future<void> updateFeatureFlag(FeatureFlag flag) async {
    if (_featureFlagMap.isEmpty) {
      throw const EmptyFeatureFlagsException();
    }

    final key = flag.key;
    if (!_featureFlagMap.containsKey(key)) {
      throw FeatureFlagNotFoundException(key);
    }

    _featureFlagMap[key] = flag;
    await _dataSource.updateFeatureFlag(flag);
  }

  Future<void> reset() async {
    try {
      _featureFlagMap.clear();
      await _dataSource.reset();
      await initFeatureFlags(_definitions);
    } catch (e) {
      throw const FeatureFlagResetException();
    }
  }
}
