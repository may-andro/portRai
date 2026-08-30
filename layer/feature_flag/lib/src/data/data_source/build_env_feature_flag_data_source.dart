import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';

/// Routes to cache or remote data source based on build environment
class BuildEnvFeatureFlagDataSource implements FeatureFlagDataSource {
  BuildEnvFeatureFlagDataSource(
    BuildConfig buildConfig,
    FeatureFlagDataSource cacheDataSourceDelegate,
    FeatureFlagDataSource remoteDataSourceDelegate,
  ) : _dataSourceDelegate = buildConfig.buildEnvironment.isFeatureFlagCached
          ? cacheDataSourceDelegate
          : remoteDataSourceDelegate;

  final FeatureFlagDataSource _dataSourceDelegate;

  @override
  FutureOr<List<FeatureFlag>> resolveFeatureFlags(
    List<FeatureFlagDefinition> definitions,
  ) {
    return _dataSourceDelegate.resolveFeatureFlags(definitions);
  }

  @override
  FutureOr<void> reset() => _dataSourceDelegate.reset();

  @override
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag) {
    return _dataSourceDelegate.updateFeatureFlag(featureFlag);
  }
}
