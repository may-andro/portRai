import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';

abstract class AppFeatureFlagRepository {
  bool isFeatureEnabled(AppFeatureFlagDefinition definition);

  Future<void> updateFeatureFlag(AppFeatureFlagEntity flag);

  Future<void> reset();

  AppFeatureFlagEntity getFeatureFlag(AppFeatureFlagDefinition definition);
}
