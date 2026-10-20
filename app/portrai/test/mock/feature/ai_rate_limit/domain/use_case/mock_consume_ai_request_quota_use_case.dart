import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:use_case/use_case.dart';

class MockConsumeAiRequestQuotaUseCase extends Mock
    implements ConsumeAiRequestQuotaUseCase {}

extension MockConsumeAiRequestQuotaUseCaseStub
    on MockConsumeAiRequestQuotaUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<ConsumeAiRequestQuotaFailure, void> result) {
    when(() => this()).thenAnswer((_) => Future.value(result));
  }
}
