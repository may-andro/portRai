import 'dart:async';

import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:firebase/firebase.dart';

class RemoteFeatureFlagDataSource implements FeatureFlagDataSource {
  RemoteFeatureFlagDataSource(this._fbRemoteConfigController);

  final FbRemoteConfigController _fbRemoteConfigController;

  @override
  List<FeatureFlag> initFeatureFlags() {
    final configValues = _fbRemoteConfigController.getAllConfigsValue();
    return configValues.entries
        .map((entry) => FeatureFlag(
              key: entry.key,
              isEnabled: entry.value.asBool(),
            ))
        .toList();
  }

  @override
  FutureOr<void> reset() => null;

  @override
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag) => null;
}
