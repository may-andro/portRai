import 'dart:async';

import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';
import 'package:firebase/firebase.dart';

class RemoteFeatureFlagDataSource implements FeatureFlagDataSource {
  RemoteFeatureFlagDataSource(this._fbRemoteConfigController);

  final FbRemoteConfigController _fbRemoteConfigController;

  @override
  List<FeatureFlag> resolveFeatureFlags(
    List<FeatureFlagDefinition> definitions,
  ) {
    final remoteConfigValues = _fbRemoteConfigController.getAllConfigsValue();

    return definitions.map((definition) {
      final remoteConfigValue = remoteConfigValues[definition.key];

      if (remoteConfigValue == null) {
        // Key doesn't exist remotely: fall back to the caller-supplied default.
        return FeatureFlag(
          key: definition.key,
          isEnabled: definition.defaultValue,
        );
      }

      final remoteValue = remoteConfigValue.asBool();
      return FeatureFlag(
        key: definition.key,
        isEnabled: remoteValue,
        hasRemoteSource: true,
        remoteValue: remoteValue,
      );
    }).toList();
  }

  @override
  FutureOr<void> reset() => null;

  @override
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag) => null;
}
