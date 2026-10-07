import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

import '../../../../../mock/feature/experience/domain/repository/mock_experience_repository.dart';

void main() {
  final experience = ExperienceEntity(
    company: 'Acme',
    position: 'Engineer',
    location: 'Amsterdam',
    startDate: DateTime(2024),
    endDate: null,
    current: true,
    employmentType: 'Full-time',
    description: 'Builds products',
    longDescription: 'Builds products for customers',
    responsibilities: const ['Coding'],
    achievements: const ['Shipped'],
    technologies: const ['Dart'],
    companyLogo: 'acme.png',
    url: null,
    id: 'acme-engineer',
  );

  group('GetExperienceUseCase', () {
    late MockExperienceRepository repository;
    late GetExperienceUseCase useCase;

    setUp(() {
      repository = MockExperienceRepository();
      useCase = GetExperienceUseCase(repository);
    });

    test(
      'should return the requested experience when the repository succeeds',
      () async {
        repository.stubGetExperience(id: experience.id, experience: experience);

        final result = await useCase(experience.id);

        expect(result.isRight, isTrue);
        expect(result.right, experience);
      },
    );

    final failures = <(Object, Type)>[
      (const ExperienceNotFoundException(), ExperienceNotFoundFailure),
      (const ExperienceNetworkException(), ExperienceNetworkFailure),
      (const ExperienceParsingException(), ExperienceDataFailure),
      (const ExperienceCacheException(), ExperienceDataFailure),
      (const ExperienceUnauthorizedException(), ExperienceUnauthorizedFailure),
      (Exception('unexpected'), ExperienceUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetExperienceThrows(id: experience.id, error: error);

          final result = await useCase(experience.id);

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
