import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetJobOpeningUseCase extends Mock implements GetJobOpeningUseCase {}

extension MockGetJobOpeningUseCaseStub on MockGetJobOpeningUseCase {
  /// Stubs `call(id)` for any ID to return [result].
  void stubCall(Either<GetJobOpeningFailure, JobOpeningEntity> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
