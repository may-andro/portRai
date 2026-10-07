import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

class MockExpertiseRepository extends Mock implements ExpertiseRepository {}

extension MockExpertiseRepositoryStub on MockExpertiseRepository {
  void stubCacheExpertise(ExpertiseEntity expertise) {
    when(() => cacheExpertise(expertise)).thenAnswer((_) async {});
  }

  void stubCacheExpertiseThrows({
    required ExpertiseEntity expertise,
    required Object error,
  }) {
    when(() => cacheExpertise(expertise)).thenThrow(error);
  }

  void stubGetAllExpertise(List<ExpertiseEntity> expertiseList) {
    when(() => getAllExpertise()).thenAnswer((_) async => expertiseList);
  }

  void stubGetAllExpertiseThrows(Object error) {
    when(() => getAllExpertise()).thenThrow(error);
  }
}
