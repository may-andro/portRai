import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSetJobSearchEnabledUseCase extends Mock
    implements SetJobSearchEnabledUseCase {}

extension MockSetJobSearchEnabledUseCaseStub on MockSetJobSearchEnabledUseCase {
  /// Stubs `call(isEnabled)` for any value to return [result].
  void stubCall(Either<SetJobSearchEnabledFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
