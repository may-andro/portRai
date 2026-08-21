import 'package:core/core.dart';
import 'package:feature_flag/feature_flag.dart' as layer;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

@register
class AppFeatureFlagMapper
    implements BiMapper<layer.FeatureFlag, AppFeatureFlagEntity> {
  const AppFeatureFlagMapper();

  @override
  layer.FeatureFlag from(AppFeatureFlagEntity entity) => layer.FeatureFlag(
    key: entity.flag.key,
    isEnabled: entity.isEnabled,
    isOverridden: entity.isOverridden,
    remoteValue: entity.remoteValue,
  );

  @override
  AppFeatureFlagEntity to(layer.FeatureFlag model) {
    final flag = AppFeatureFlag.fromKey(model.key);
    if (flag == null) {
      throw ArgumentError('Unknown feature flag key: ${model.key}');
    }

    return AppFeatureFlagEntity(
      flag: flag,
      isEnabled: model.isEnabled,
      isOverridden: model.isOverridden,
      remoteValue: model.remoteValue,
      displayName: _getDisplayName(flag),
      description: _getDescription(flag),
    );
  }

  String? _getDisplayName(AppFeatureFlag flag) {
    return switch (flag) {
      AppFeatureFlag.newDashboard => 'New Dashboard',
      AppFeatureFlag.analytics => 'Analytics',
      AppFeatureFlag.darkMode => 'Dark Mode',
      AppFeatureFlag.betaFeatures => 'Beta Features',
      AppFeatureFlag.offlineMode => 'Offline Mode',
      AppFeatureFlag.languageSelector => 'Language Selector',
    };
  }

  String? _getDescription(AppFeatureFlag flag) {
    return switch (flag) {
      AppFeatureFlag.newDashboard =>
        'Enable the redesigned dashboard interface',
      AppFeatureFlag.analytics => 'Enable analytics tracking and reporting',
      AppFeatureFlag.darkMode => 'Enable dark mode theme support',
      AppFeatureFlag.betaFeatures => 'Enable experimental beta features',
      AppFeatureFlag.offlineMode => 'Enable offline mode for the app',
      AppFeatureFlag.languageSelector => 'Show language selection in settings',
    };
  }
}
