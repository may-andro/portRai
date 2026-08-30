import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

import '../../../../../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';

void main() {
  const definition = AppFeatureFlagDefinition(
    key: 'feature_language_selector',
    defaultValue: false,
    displayName: 'Language Selector',
    description: 'Enables the language selector on portfolio page',
  );

  group('IsFeatureEnabledUseCase', () {
    late MockAppFeatureFlagRepository repository;
    late IsFeatureEnabledUseCase useCase;

    setUp(() {
      repository = MockAppFeatureFlagRepository();
      useCase = IsFeatureEnabledUseCase(repository);
    });

    test(
      'should return true when the repository reports the flag as enabled',
      () async {
        repository.stubIsFeatureEnabled(
          definition: definition,
          isEnabled: true,
        );

        final result = await useCase(definition);

        expect(result.isRight, isTrue);
        expect(result.right, isTrue);
      },
    );

    test(
      'should return false when the repository reports the flag as disabled',
      () async {
        repository.stubIsFeatureEnabled(
          definition: definition,
          isEnabled: false,
        );

        final result = await useCase(definition);

        expect(result.isRight, isTrue);
        expect(result.right, isFalse);
      },
    );

    test(
      'should return FeatureFlagUnknownFailure when the repository throws',
      () async {
        repository.stubIsFeatureEnabledThrows(
          definition: definition,
          error: Exception('boom'),
        );

        final result = await useCase(definition);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<FeatureFlagUnknownFailure>());
      },
    );
  });
}
