import 'dart:async';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';

abstract class FeatureFlagDataSource {
  /// Resolves every entry in [definitions] into a [FeatureFlag]: a value
  /// found in the remote source wins, otherwise the definition's
  /// [FeatureFlagDefinition.defaultValue] is used.
  FutureOr<List<FeatureFlag>> resolveFeatureFlags(
    List<FeatureFlagDefinition> definitions,
  );
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag);
  FutureOr<void> reset();
}
