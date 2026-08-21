import 'dart:async';

import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_exception.dart';

/// Controller for managing feature flags throughout the application.
///
/// Example:
/// ```dart
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

  Future<void> initFeatureFlags() async {
    try {
      _featureFlagMap.clear();
      final featureFlags = await _dataSource.initFeatureFlags();

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
      await initFeatureFlags();
    } catch (e) {
      throw const FeatureFlagResetException();
    }
  }
}
