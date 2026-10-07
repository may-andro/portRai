import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/setting/domain/feature_flag/setting_feature_flags.dart';

void main() {
  group('SettingFeatureFlags', () {
    test('should expose the language selector definition when all is read', () {
      expect(SettingFeatureFlags.all, [SettingFeatureFlags.languageSelector]);
    });

    test('should define the language selector metadata when accessed', () {
      expect(
        SettingFeatureFlags.languageSelector.key,
        'feature_language_selector',
      );
      expect(SettingFeatureFlags.languageSelector.defaultValue, isFalse);
      expect(
        SettingFeatureFlags.languageSelector.displayName,
        'Language Selector',
      );
      expect(
        SettingFeatureFlags.languageSelector.description,
        'Enables the language selector on portfolio page',
      );
    });
  });
}
