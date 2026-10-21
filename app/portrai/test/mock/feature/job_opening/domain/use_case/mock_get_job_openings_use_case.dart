import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetJobOpeningsUseCase extends Mock implements GetJobOpeningsUseCase {}

extension MockGetJobOpeningsUseCaseStub on MockGetJobOpeningsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetJobOpeningsFailure, List<JobOpeningEntity>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
