import 'package:core/core.dart';
import 'package:feature_flag/feature_flag.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

/// Maps between the layer's generic [FeatureFlag] and [AppFeatureFlagEntity].
///
/// Implements only `Mapper` (entity to layer model) because mapping a [FeatureFlag] back into an
/// [AppFeatureFlagEntity] needs its matching [AppFeatureFlagDefinition] too -
/// that information no longer lives inside the layer model itself, since the
/// catalog of known flags is now owned by each feature, not by this module.
@register
class AppFeatureFlagMapper
    implements Mapper<AppFeatureFlagEntity, FeatureFlag> {
  const AppFeatureFlagMapper();

  @override
  FeatureFlag map(AppFeatureFlagEntity from) => FeatureFlag(
    key: from.flag.key,
    isEnabled: from.isEnabled,
    isOverridden: from.isOverridden,
    hasRemoteSource: from.hasRemoteSource,
    remoteValue: from.remoteValue,
  );

  AppFeatureFlagEntity toEntity(
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
