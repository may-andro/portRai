import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

class MockExperienceRepository extends Mock implements ExperienceRepository {}

extension MockExperienceRepositoryStub on MockExperienceRepository {
  void stubCacheExperience(ExperienceEntity experience) {
    when(() => cacheExperience(experience)).thenAnswer((_) async {});
  }

  void stubGetExperience({
    required String id,
    required ExperienceEntity experience,
  }) {
    when(() => getExperience(id)).thenAnswer((_) async => experience);
  }

  void stubGetExperienceThrows({required String id, required Object error}) {
    when(() => getExperience(id)).thenThrow(error);
  }

  void stubGetExperiences(List<ExperienceEntity> experiences) {
    when(getExperiences).thenAnswer((_) async => experiences);
  }

  void stubGetExperiencesThrows(Object error) {
    when(getExperiences).thenThrow(error);
  }
}
