import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

import '../../../../../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';

void main() {
  const definition = AppFeatureFlagDefinition(
    key: 'feature_experiences_section',
    defaultValue: false,
    displayName: 'Experiences Section',
    description: 'Enables the experience section on portfolio page',
  );
  const entity = AppFeatureFlagEntity(
    flag: definition,
    isEnabled: true,
    isOverridden: true,
    hasRemoteSource: true,
    remoteValue: false,
  );

  group('UpdateFeatureFlagUseCase', () {
    late MockAppFeatureFlagRepository repository;
    late UpdateFeatureFlagUseCase useCase;

    setUp(() {
      repository = MockAppFeatureFlagRepository();
      useCase = UpdateFeatureFlagUseCase(repository);
    });

    test(
      'should return success when the repository update completes',
      () async {
        repository.stubUpdateFeatureFlag(entity);

        final result = await useCase(entity);

        expect(result.isRight, isTrue);
        verify(() => repository.updateFeatureFlag(entity)).called(1);
      },
    );

    test(
      'should return FeatureFlagUpdateUnknownFailure when the repository throws',
      () async {
        repository.stubUpdateFeatureFlagThrows(
          flag: entity,
          error: Exception('boom'),
        );

        final result = await useCase(entity);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<FeatureFlagUpdateUnknownFailure>());
      },
    );
  });
}
