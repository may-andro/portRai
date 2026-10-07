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

  group('GetExperiencesUseCase', () {
    late MockExperienceRepository repository;
    late GetExperiencesUseCase useCase;

    setUp(() {
      repository = MockExperienceRepository();
      useCase = GetExperiencesUseCase(repository);
    });

    test(
      'should return all experiences when the repository succeeds',
      () async {
        repository.stubGetExperiences([experience]);

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right, [experience]);
      },
    );

    test(
      'should return a not found failure when the repository reports missing experiences',
      () async {
        repository.stubGetExperiencesThrows(
          const ExperienceNotFoundException(),
        );

        final result = await useCase();

        expect(result.left, isA<ExperiencesNotFoundFailure>());
      },
    );

    test(
      'should return a data failure when the repository reports a cache error',
      () async {
        repository.stubGetExperiencesThrows(const ExperienceCacheException());

        final result = await useCase();

        expect(result.left, isA<ExperiencesDataFailure>());
      },
    );

    test(
      'should return an unknown failure when the repository throws an unexpected error',
      () async {
        repository.stubGetExperiencesThrows(Exception('boom'));

        final result = await useCase();

        expect(result.left, isA<ExperiencesUnknownFailure>());
      },
    );
  });
}
