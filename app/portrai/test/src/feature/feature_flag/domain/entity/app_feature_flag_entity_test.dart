import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

void main() {
  const featureFlagDefinition = AppFeatureFlagDefinition(
    key: 'feature_testimonials_section',
    defaultValue: false,
    displayName: 'Testimonials Section',
    description: 'Enables the testimonials section on portfolio page',
  );
  const replacementDefinition = AppFeatureFlagDefinition(
    key: 'feature_projects_section',
    defaultValue: true,
    displayName: 'Projects Section',
    description: 'Enables the projects section on portfolio page',
  );

  group('AppFeatureFlagEntity', () {
    test('should expose key, name and description when derived from flag', () {
      const entity = AppFeatureFlagEntity(
        flag: featureFlagDefinition,
        isEnabled: true,
        isOverridden: false,
      );

      expect(entity.key, featureFlagDefinition.key);
      expect(entity.name, featureFlagDefinition.displayName);
      expect(entity.description, featureFlagDefinition.description);
    });

    test(
      'should return true from isModified when overridden and remoteValue exists',
      () {
        const entity = AppFeatureFlagEntity(
          flag: featureFlagDefinition,
          isEnabled: true,
          isOverridden: true,
          hasRemoteSource: true,
          remoteValue: false,
        );

        expect(entity.isModified, isTrue);
      },
    );

    test(
      'should return false from isModified when override or remoteValue is missing',
      () {
        const overriddenWithoutRemoteValue = AppFeatureFlagEntity(
          flag: featureFlagDefinition,
          isEnabled: true,
          isOverridden: true,
        );
        const notOverridden = AppFeatureFlagEntity(
          flag: featureFlagDefinition,
          isEnabled: true,
          isOverridden: false,
          remoteValue: false,
        );

        expect(overriddenWithoutRemoteValue.isModified, isFalse);
        expect(notOverridden.isModified, isFalse);
      },
    );

    test(
      'should return the correct status description when source and enabled state vary',
      () {
        const cases = <({AppFeatureFlagEntity entity, String description})>[
          (
            entity: AppFeatureFlagEntity(
              flag: featureFlagDefinition,
              isEnabled: true,
              isOverridden: true,
            ),
            description: 'Enabled (Override)',
          ),
          (
            entity: AppFeatureFlagEntity(
              flag: featureFlagDefinition,
              isEnabled: false,
              isOverridden: true,
            ),
            description: 'Disabled (Override)',
          ),
          (
            entity: AppFeatureFlagEntity(
              flag: featureFlagDefinition,
              isEnabled: true,
              isOverridden: false,
              hasRemoteSource: true,
            ),
            description: 'Enabled (Remote)',
          ),
          (
            entity: AppFeatureFlagEntity(
              flag: featureFlagDefinition,
              isEnabled: false,
              isOverridden: false,
              hasRemoteSource: true,
            ),
            description: 'Disabled (Remote)',
          ),
          (
            entity: AppFeatureFlagEntity(
              flag: featureFlagDefinition,
              isEnabled: true,
              isOverridden: false,
            ),
            description: 'Enabled (Local)',
          ),
          (
            entity: AppFeatureFlagEntity(
              flag: featureFlagDefinition,
              isEnabled: false,
              isOverridden: false,
            ),
            description: 'Disabled (Local)',
          ),
        ];

        for (final testCase in cases) {
          expect(testCase.entity.statusDescription, testCase.description);
        }
      },
    );

    test('should update all supported fields when copyWith is called', () {
      const entity = AppFeatureFlagEntity(
        flag: featureFlagDefinition,
        isEnabled: false,
        isOverridden: false,
      );

      final result = entity.copyWith(
        flag: replacementDefinition,
        isEnabled: true,
        isOverridden: true,
        hasRemoteSource: true,
        remoteValue: false,
      );

      expect(
        result,
        const AppFeatureFlagEntity(
          flag: replacementDefinition,
          isEnabled: true,
          isOverridden: true,
          hasRemoteSource: true,
          remoteValue: false,
        ),
      );
    });
  });
}
