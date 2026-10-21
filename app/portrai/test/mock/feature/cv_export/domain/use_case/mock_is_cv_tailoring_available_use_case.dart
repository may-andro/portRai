import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsCvTailoringAvailableUseCase extends Mock
    implements IsCvTailoringAvailableUseCase {}

extension MockIsCvTailoringAvailableUseCaseStub
    on MockIsCvTailoringAvailableUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<NoFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
