import 'package:feature_flag/feature_flag.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

/// Maps between the layer's generic [FeatureFlag] and [AppFeatureFlagEntity].
///
/// Doesn't implement `BiMapper` because mapping a [FeatureFlag] back into an
/// [AppFeatureFlagEntity] needs its matching [AppFeatureFlagDefinition] too -
/// that information no longer lives inside the layer model itself, since the
/// catalog of known flags is now owned by each feature, not by this module.
@register
class AppFeatureFlagMapper {
  const AppFeatureFlagMapper();

  FeatureFlag from(AppFeatureFlagEntity entity) => FeatureFlag(
    key: entity.flag.key,
    isEnabled: entity.isEnabled,
    isOverridden: entity.isOverridden,
    hasRemoteSource: entity.hasRemoteSource,
    remoteValue: entity.remoteValue,
  );

  AppFeatureFlagEntity to(
    FeatureFlag model,
    AppFeatureFlagDefinition definition,
  ) {
    return AppFeatureFlagEntity(
      flag: definition,
      isEnabled: model.isEnabled,
      isOverridden: model.isOverridden,
      hasRemoteSource: model.hasRemoteSource,
      remoteValue: model.remoteValue,
    );
  }
}
