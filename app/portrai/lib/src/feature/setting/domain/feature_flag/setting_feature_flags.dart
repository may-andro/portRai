import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `setting` feature.
abstract final class SettingFeatureFlags {
  static const languageSelector = AppFeatureFlagDefinition(
    key: 'feature_language_selector',
    defaultValue: false,
    displayName: 'Language Selector',
    description: 'Enables the language selector on portfolio page',
  );

  static const all = [languageSelector];
}
