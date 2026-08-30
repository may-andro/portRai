import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

import '../../../../../mock/feature/feature_flag/domain/registry/mock_app_feature_flag_definition_registry.dart';
import '../../../../../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';

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
  const testimonialsEntity = AppFeatureFlagEntity(
    flag: testimonialsDefinition,
    isEnabled: true,
    isOverridden: false,
  );
  const servicesEntity = AppFeatureFlagEntity(
    flag: servicesDefinition,
    isEnabled: false,
    isOverridden: true,
    hasRemoteSource: true,
    remoteValue: true,
  );

  group('GetAllFeatureFlagsUseCase', () {
    late MockAppFeatureFlagRepository repository;
    late MockAppFeatureFlagDefinitionRegistry registry;
    late GetAllFeatureFlagsUseCase useCase;

    setUp(() {
      repository = MockAppFeatureFlagRepository();
      registry = MockAppFeatureFlagDefinitionRegistry();
      useCase = GetAllFeatureFlagsUseCase(repository, registry);
    });

    test(
      'should return all mapped flags when definitions are registered',
      () async {
        registry.stubAll([testimonialsDefinition, servicesDefinition]);
        repository.stubGetFeatureFlag(
          definition: testimonialsDefinition,
          entity: testimonialsEntity,
        );
        repository.stubGetFeatureFlag(
          definition: servicesDefinition,
          entity: servicesEntity,
        );

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right, [testimonialsEntity, servicesEntity]);
      },
    );

    test(
      'should return FeatureFlagsNotFoundFailure when no definitions are registered',
      () async {
        registry.stubAll(const []);

        final result = await useCase();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<FeatureFlagsNotFoundFailure>());
      },
    );

    test(
      'should return FeatureFlagsUnknownFailure when reading a registered flag throws',
      () async {
        registry.stubAll([testimonialsDefinition]);
        repository.stubGetFeatureFlagThrows(
          definition: testimonialsDefinition,
          error: Exception('boom'),
        );

        final result = await useCase();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<FeatureFlagsUnknownFailure>());
      },
    );
  });
}
