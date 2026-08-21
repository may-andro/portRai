import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';

abstract class AppFeatureFlagRepository {
  List<AppFeatureFlagEntity> getAllFeatureFlags();

  bool isFeatureEnabled(AppFeatureFlag flag);

  Future<void> updateFeatureFlag(AppFeatureFlagEntity flag);

  Future<void> reset();

  AppFeatureFlagEntity getFeatureFlag(AppFeatureFlag flag);
}
