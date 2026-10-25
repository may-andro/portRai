import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

import '../../../../../mock/feature/experience/domain/repository/mock_experience_repository.dart';

void main() {
  group('RefreshExperiencesUseCase', () {
    late MockExperienceRepository repository;
    late RefreshExperiencesUseCase useCase;

    setUp(() {
      repository = MockExperienceRepository();
      useCase = RefreshExperiencesUseCase(repository);
    });

    test(
      'should succeed when the repository refreshes the experiences',
      () async {
        repository.stubRefreshExperiences();

        final result = await useCase();

        expect(result.isRight, isTrue);
      },
    );

    final failures = <(Object, Type)>[
      (const ExperienceNetworkException(), RefreshExperiencesNetworkFailure),
      (
        const ExperienceUnauthorizedException(),
        RefreshExperiencesNetworkFailure,
      ),
      (const ExperienceNotFoundException(), RefreshExperiencesDataFailure),
      (const ExperienceParsingException(), RefreshExperiencesDataFailure),
      (const ExperienceCacheException(), RefreshExperiencesDataFailure),
      (Exception('unexpected'), RefreshExperiencesUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubRefreshExperiencesThrows(error);

          final result = await useCase();

          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
