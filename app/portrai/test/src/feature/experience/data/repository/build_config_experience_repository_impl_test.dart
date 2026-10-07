import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/data/repository/build_config_experience_repository_impl.dart';
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

  for (final environment in BuildEnvironment.values) {
    group('BuildConfigExperienceRepositoryImpl ($environment)', () {
      late MockExperienceRepository remote;
      late MockExperienceRepository asset;
      late BuildConfigExperienceRepositoryImpl repository;
      late MockExperienceRepository selected;
      late MockExperienceRepository unselected;

      setUp(() {
        remote = MockExperienceRepository();
        asset = MockExperienceRepository();
        repository = BuildConfigExperienceRepositoryImpl(
          BuildConfig(buildEnvironment: environment),
          remote,
          asset,
        );
        selected = environment == BuildEnvironment.prod ? remote : asset;
        unselected = environment == BuildEnvironment.prod ? asset : remote;
      });

      test(
        'should delegate experience reads to the selected source when requested',
        () async {
          selected.stubGetExperience(id: experience.id, experience: experience);

          expect(await repository.getExperience(experience.id), experience);
          verify(() => selected.getExperience(experience.id)).called(1);
          verifyNever(() => unselected.getExperience(experience.id));
        },
      );

      test(
        'should delegate list reads to the selected source when requested',
        () async {
          selected.stubGetExperiences([experience]);

          expect(await repository.getExperiences(), [experience]);
          verify(() => selected.getExperiences()).called(1);
          verifyNever(() => unselected.getExperiences());
        },
      );

      test(
        'should delegate cache writes to the selected source when requested',
        () async {
          selected.stubCacheExperience(experience);

          await repository.cacheExperience(experience);

          verify(() => selected.cacheExperience(experience)).called(1);
          verifyNever(() => unselected.cacheExperience(experience));
        },
      );
    });
  }
}
