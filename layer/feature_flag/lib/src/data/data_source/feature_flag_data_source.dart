import 'dart:async';
import 'package:feature_flag/src/feature_flag.dart';

abstract class FeatureFlagDataSource {
  FutureOr<List<FeatureFlag>> initFeatureFlags();
  FutureOr<void> updateFeatureFlag(FeatureFlag featureFlag);
  FutureOr<void> reset();
}
