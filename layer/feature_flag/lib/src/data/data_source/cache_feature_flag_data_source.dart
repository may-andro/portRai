import 'dart:async';

import 'package:feature_flag/src/data/cache/feature_flag_cache.dart';
import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';

/// Wraps a delegate data source with persistent SQLite caching + developer
/// override support.
///
/// For each resolved flag:
/// - a developer override (in the cache) always wins, but its remote
///   metadata is refreshed so reverting the override still targets the
///   *current* remote value;
/// - otherwise, a flag with a remote source always reflects the delegate's
///   (fresh) remote value;
/// - a flag without a remote source (`hasRemoteSource == false`) is
///   local-only, so its last cached value is kept - falling back to the
///   definition's default only the first time it's ever resolved.
class CacheFeatureFlagDataSource implements FeatureFlagDataSource {
  const CacheFeatureFlagDataSource(
    this._delegateDataSource,
    this._featureFlagCache,
  );

  final FeatureFlagDataSource _delegateDataSource;
  final FeatureFlagCache _featureFlagCache;

  @override
  Future<List<FeatureFlag>> resolveFeatureFlags(
    List<FeatureFlagDefinition> definitions,
  ) async {
    final delegateFlags = await _delegateDataSource.resolveFeatureFlags(
      definitions,
    );
    final cachedFlags = await _featureFlagCache.getAll();
    final cachedByKey = {for (final flag in cachedFlags) flag.key: flag};

    final resolved = delegateFlags
        .map(
          (delegateFlag) =>
              _resolve(delegateFlag, cachedByKey[delegateFlag.key]),
        )
        .toList();

    await _cacheFlags(resolved);
    return resolved;
  }

  FeatureFlag _resolve(FeatureFlag delegateFlag, FeatureFlag? cachedFlag) {
    if (cachedFlag != null && cachedFlag.isOverridden) {
      return cachedFlag.copyWith(
        hasRemoteSource: delegateFlag.hasRemoteSource,
        remoteValue: delegateFlag.remoteValue,
      );
    }

    if (delegateFlag.hasRemoteSource) {
      return delegateFlag;
    }

    // Local-only flag: keep the previously cached value, if any.
    return cachedFlag ?? delegateFlag;
  }

  @override
  Future<void> reset() => _featureFlagCache.deleteAll();

  @override
  Future<void> updateFeatureFlag(FeatureFlag featureFlag) {
    if (featureFlag.isOverridden) {
      return _featureFlagCache.putOverride(featureFlag);
    }
    return _featureFlagCache.put(featureFlag);
  }

  Future<void> _cacheFlags(List<FeatureFlag> flags) async {
    if (flags.isEmpty) return;
    await Future.wait(flags.map((flag) => _featureFlagCache.put(flag)));
  }
}
