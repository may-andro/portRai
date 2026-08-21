import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

void main() {
  group('AppFeatureFlagEntity', () {
    test('should create entity with all properties', () {
      const entity = AppFeatureFlagEntity(
        flag: AppFeatureFlag.newDashboard,
        isEnabled: true,
        isOverridden: false,
        remoteValue: true,
        displayName: 'Test Feature',
        description: 'A test feature flag',
      );

      expect(entity.flag, AppFeatureFlag.newDashboard);
      expect(entity.key, 'new_dashboard');
      expect(entity.isEnabled, true);
      expect(entity.isOverridden, false);
      expect(entity.remoteValue, true);
      expect(entity.displayName, 'Test Feature');
      expect(entity.description, 'A test feature flag');
    });

    test('should format enum name when displayName is null', () {
      const entity = AppFeatureFlagEntity(
        flag: AppFeatureFlag.newDashboard,
        isEnabled: true,
        isOverridden: false,
      );

      expect(entity.name, 'New Dashboard');
    });

    test('should use displayName when provided', () {
      const entity = AppFeatureFlagEntity(
        flag: AppFeatureFlag.newDashboard,
        isEnabled: true,
        isOverridden: false,
        displayName: 'Custom Dashboard',
      );

      expect(entity.name, 'Custom Dashboard');
    });

    test('should detect if flag is modified', () {
      const modifiedEntity = AppFeatureFlagEntity(
        flag: AppFeatureFlag.analytics,
        isEnabled: true,
        isOverridden: true,
        remoteValue: false,
      );

      const notModifiedEntity = AppFeatureFlagEntity(
        flag: AppFeatureFlag.analytics,
        isEnabled: true,
        isOverridden: false,
      );

      expect(modifiedEntity.isModified, true);
      expect(notModifiedEntity.isModified, false);
    });

    test('should provide correct status description', () {
      const remoteEnabled = AppFeatureFlagEntity(
        flag: AppFeatureFlag.darkMode,
        isEnabled: true,
        isOverridden: false,
      );

      const remoteDisabled = AppFeatureFlagEntity(
        flag: AppFeatureFlag.darkMode,
        isEnabled: false,
        isOverridden: false,
      );

      const overrideEnabled = AppFeatureFlagEntity(
        flag: AppFeatureFlag.darkMode,
        isEnabled: true,
        isOverridden: true,
      );

      const overrideDisabled = AppFeatureFlagEntity(
        flag: AppFeatureFlag.darkMode,
        isEnabled: false,
        isOverridden: true,
      );

      expect(remoteEnabled.statusDescription, 'Enabled (Remote)');
      expect(remoteDisabled.statusDescription, 'Disabled (Remote)');
      expect(overrideEnabled.statusDescription, 'Enabled (Override)');
      expect(overrideDisabled.statusDescription, 'Disabled (Override)');
    });

    test('should support copyWith', () {
      const original = AppFeatureFlagEntity(
        flag: AppFeatureFlag.betaFeatures,
        isEnabled: true,
        isOverridden: false,
      );

      final copied = original.copyWith(isEnabled: false, isOverridden: true);

      expect(copied.flag, AppFeatureFlag.betaFeatures);
      expect(copied.isEnabled, false);
      expect(copied.isOverridden, true);
    });

    test('should support equality comparison', () {
      const entity1 = AppFeatureFlagEntity(
        flag: AppFeatureFlag.offlineMode,
        isEnabled: true,
        isOverridden: false,
      );

      const entity2 = AppFeatureFlagEntity(
        flag: AppFeatureFlag.offlineMode,
        isEnabled: true,
        isOverridden: false,
      );

      const entity3 = AppFeatureFlagEntity(
        flag: AppFeatureFlag.offlineMode,
        isEnabled: false,
        isOverridden: false,
      );

      expect(entity1, equals(entity2));
      expect(entity1, isNot(equals(entity3)));
    });
  });

  group('AppFeatureFlag', () {
    test('should have correct keys', () {
      expect(AppFeatureFlag.newDashboard.key, 'new_dashboard');
      expect(AppFeatureFlag.analytics.key, 'analytics_feature');
      expect(AppFeatureFlag.darkMode.key, 'dark_mode');
      expect(AppFeatureFlag.betaFeatures.key, 'beta_features');
      expect(AppFeatureFlag.offlineMode.key, 'offline_mode');
    });

    test('should have default values', () {
      expect(AppFeatureFlag.newDashboard.defaultValue, false);
      expect(AppFeatureFlag.analytics.defaultValue, true);
      expect(AppFeatureFlag.darkMode.defaultValue, false);
      expect(AppFeatureFlag.betaFeatures.defaultValue, false);
      expect(AppFeatureFlag.offlineMode.defaultValue, false);
    });

    test('should find flag by key', () {
      expect(
        AppFeatureFlag.fromKey('new_dashboard'),
        AppFeatureFlag.newDashboard,
      );
      expect(
        AppFeatureFlag.fromKey('analytics_feature'),
        AppFeatureFlag.analytics,
      );
      expect(AppFeatureFlag.fromKey('unknown_key'), isNull);
    });
  });
}
