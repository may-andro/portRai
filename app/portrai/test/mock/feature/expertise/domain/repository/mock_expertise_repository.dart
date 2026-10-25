import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

class MockExpertiseRepository extends Mock implements ExpertiseRepository {}

extension MockExpertiseRepositoryStub on MockExpertiseRepository {
  void stubCacheAllExpertise(List<ExpertiseEntity> expertiseList) {
    when(() => cacheAllExpertise(expertiseList)).thenAnswer((_) async {});
  }

  void stubCacheAllExpertiseThrows({
    required List<ExpertiseEntity> expertiseList,
    required Object error,
  }) {
    when(() => cacheAllExpertise(expertiseList)).thenThrow(error);
  }

  void stubGetAllExpertise(List<ExpertiseEntity> expertiseList) {
    when(() => getAllExpertise()).thenAnswer((_) async => expertiseList);
  }

  void stubGetAllExpertiseThrows(Object error) {
    when(() => getAllExpertise()).thenThrow(error);
  }

  void stubRefreshAllExpertise() {
    when(() => refreshAllExpertise()).thenAnswer((_) async {});
  }

  void stubRefreshAllExpertiseThrows(Object error) {
    when(() => refreshAllExpertise()).thenThrow(error);
  }
}
