import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsJobOpeningInsightsAvailableUseCase extends Mock
    implements IsJobOpeningInsightsAvailableUseCase {}

extension MockIsJobOpeningInsightsAvailableUseCaseStub
    on MockIsJobOpeningInsightsAvailableUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<NoFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
