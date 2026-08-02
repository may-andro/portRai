import 'dart:async';

import 'package:feature_flag/src/data/cache/feature_flag_cache.dart';
import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';

class CacheFeatureFlagDataSource implements FeatureFlagDataSource {
  const CacheFeatureFlagDataSource(
    this._delegateDataSource,
    this._featureFlagCache,
  );

  final FeatureFlagDataSource _delegateDataSource;
  final FeatureFlagCache _featureFlagCache;

  @override
  FutureOr<List<FeatureFlag>> initFeatureFlags() async {
    final cachedFlags = await _featureFlagCache.getAll();
    final delegateFlags = await _delegateDataSource.initFeatureFlags();

    if (cachedFlags.isEmpty) {
      // Cache all delegate flags and return them
      await _cacheFlags(delegateFlags);
      return delegateFlags;
    }

    // Merge: cached flags override delegate flags, new delegate flags are added
    final merged = _mergeFlags(delegateFlags, cachedFlags);
    
    // Cache any new flags from delegate
    final newFlags = _findNewFlags(delegateFlags, cachedFlags);
    if (newFlags.isNotEmpty) {
      await _cacheFlags(newFlags);
    }

    return merged;
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
  List<FeatureFlag> _mergeFlags(
    List<FeatureFlag> delegateFlags,
    List<FeatureFlag> cachedFlags,
  ) {
    final cachedMap = {for (var flag in cachedFlags) flag.key: flag};
    final result = <FeatureFlag>[];

    for (final delegateFlag in delegateFlags) {
      result.add(cachedMap[delegateFlag.key] ?? delegateFlag);
    }

    return result;
  }

  List<FeatureFlag> _findNewFlags(
    List<FeatureFlag> delegateFlags,
    List<FeatureFlag> cachedFlags,
  ) {
    final cachedKeys = cachedFlags.map((f) => f.key).toSet();
    return delegateFlags.where((f) => !cachedKeys.contains(f.key)).toList();
  }

  Future<void> _cacheFlags(List<FeatureFlag> flags) async {
    if (flags.isEmpty) return;
    await Future.wait(flags.map((flag) => _featureFlagCache.put(flag)));
  }
}
