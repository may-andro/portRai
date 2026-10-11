import 'package:feature_flag/feature_flag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/data/mapper/app_feature_flag_mapper.dart';
import 'package:portrai/src/feature/feature_flag/data/repository/app_feature_flag_repository_impl.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

import '../../../../../mock/utility/mock_feature_flag_controller.dart';

void main() {
  const testimonialsDefinition = AppFeatureFlagDefinition(
    key: 'feature_testimonials_section',
    defaultValue: false,
    displayName: 'Testimonials Section',
    description: 'Enables the testimonials section on portfolio page',
  );
  const servicesDefinition = AppFeatureFlagDefinition(
    key: 'feature_services_section',
    defaultValue: false,
    displayName: 'Services Section',
    description: 'Enables the services section on portfolio page',
  );

  group('AppFeatureFlagRepositoryImpl', () {
    late MockFeatureFlagController controller;
    late AppFeatureFlagRepositoryImpl repository;

    setUp(() {
      controller = MockFeatureFlagController();
      repository = AppFeatureFlagRepositoryImpl(
        controller,
        const AppFeatureFlagMapper(),
      );
    });

    group('isFeatureEnabled', () {
      test(
        'should return the controller value when the feature flag exists',
        () {
          controller.stubIsFeatureEnabled(
            key: testimonialsDefinition.key,
            isEnabled: true,
          );

          final result = repository.isFeatureEnabled(testimonialsDefinition);

          expect(result, isTrue);
        },
      );

      test(
        'should fall back to the definition default value when the controller throws',
        () {
          controller.stubIsFeatureEnabledThrows(
            key: testimonialsDefinition.key,
            error: Exception('not initialized'),
          );

          final result = repository.isFeatureEnabled(testimonialsDefinition);

          expect(result, testimonialsDefinition.defaultValue);
        },
      );
    });

    group('updateFeatureFlag', () {
      test(
        'should map and delegate to the controller when updateFeatureFlag is called',
        () async {
          const entity = AppFeatureFlagEntity(
            flag: servicesDefinition,
            isEnabled: true,
            isOverridden: true,
            hasRemoteSource: true,
            remoteValue: false,
          );
          const layerFlag = FeatureFlag(
            key: 'feature_services_section',
            isEnabled: true,
            isOverridden: true,
            hasRemoteSource: true,
            remoteValue: false,
          );
          controller.stubUpdateFeatureFlag(layerFlag);

          await repository.updateFeatureFlag(entity);

          verify(() => controller.updateFeatureFlag(layerFlag)).called(1);
        },
      );
    });

    group('reset', () {
      test('should delegate to the controller when reset is called', () async {
        controller.stubReset();

        await repository.reset();

        verify(() => controller.reset()).called(1);
      });
    });

    group('getFeatureFlag', () {
      test(
        'should return the mapped entity when a matching controller flag is found',
        () {
          controller.stubGetAllFeatureFlags([
            const FeatureFlag(
              key: 'feature_testimonials_section',
              isEnabled: true,
              isOverridden: true,
              hasRemoteSource: true,
              remoteValue: false,
            ),
            const FeatureFlag(
              key: 'feature_services_section',
              isEnabled: false,
            ),
          ]);

          final result = repository.getFeatureFlag(testimonialsDefinition);

          expect(
            result,
            const AppFeatureFlagEntity(
              flag: testimonialsDefinition,
              isEnabled: true,
              isOverridden: true,
              hasRemoteSource: true,
              remoteValue: false,
            ),
          );
        },
      );

      test(
        'should return a default entity when the controller has no matching flag',
        () {
          controller.stubGetAllFeatureFlags([
            const FeatureFlag(key: 'feature_services_section', isEnabled: true),
          ]);

          final result = repository.getFeatureFlag(testimonialsDefinition);

          expect(
            result,
            const AppFeatureFlagEntity(
              flag: testimonialsDefinition,
              isEnabled: false,
              isOverridden: false,
            ),
          );
        },
      );

      test(
        'should return a default entity when the controller throws while reading flags',
        () {
          controller.stubGetAllFeatureFlagsThrows(Exception('read failed'));

          final result = repository.getFeatureFlag(testimonialsDefinition);

          expect(
            result,
            const AppFeatureFlagEntity(
              flag: testimonialsDefinition,
              isEnabled: false,
              isOverridden: false,
            ),
          );
        },
      );
    });
  });
}
