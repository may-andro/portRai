enum AppFeatureFlag {
  newDashboard('new_dashboard', defaultValue: false),
  analytics('analytics_feature', defaultValue: true),
  darkMode('dark_mode', defaultValue: false),
  betaFeatures('beta_features', defaultValue: false),
  offlineMode('offline_mode', defaultValue: false),
  languageSelector('feature_language_selector', defaultValue: true);

  const AppFeatureFlag(this.key, {required this.defaultValue});

  final String key;
  final bool defaultValue;

  static AppFeatureFlag? fromKey(String key) {
    try {
      return values.firstWhere((flag) => flag.key == key);
    } catch (e) {
      return null;
    }
  }
}
