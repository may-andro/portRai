import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

class MockJobOpeningRepository extends Mock implements JobOpeningRepository {}

extension MockJobOpeningRepositoryStub on MockJobOpeningRepository {
  void stubGetJobOpenings(List<JobOpeningEntity> jobOpenings) {
    when(() => getJobOpenings(any())).thenAnswer((_) async => jobOpenings);
  }

  void stubGetJobOpeningsThrows(Object error) {
    when(() => getJobOpenings(any())).thenThrow(error);
  }

  void stubGetJobOpening(JobOpeningEntity jobOpening) {
    when(
      () => getJobOpening(
        userId: any(named: 'userId'),
        id: any(named: 'id'),
      ),
    ).thenAnswer((_) async => jobOpening);
  }

  void stubGetJobOpeningThrows(Object error) {
    when(
      () => getJobOpening(
        userId: any(named: 'userId'),
        id: any(named: 'id'),
      ),
    ).thenThrow(error);
  }
}
