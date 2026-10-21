import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsJobSearchEnabledUseCase extends Mock
    implements IsJobSearchEnabledUseCase {}

extension MockIsJobSearchEnabledUseCaseStub on MockIsJobSearchEnabledUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<IsJobSearchEnabledFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
