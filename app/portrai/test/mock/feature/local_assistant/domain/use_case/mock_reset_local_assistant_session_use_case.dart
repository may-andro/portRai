import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/reset_local_assistant_session_use_case.dart';
import 'package:use_case/use_case.dart';

class MockResetLocalAssistantSessionUseCase extends Mock
    implements ResetLocalAssistantSessionUseCase {}

extension MockResetLocalAssistantSessionUseCaseStub
    on MockResetLocalAssistantSessionUseCase {
  void stubCall(Either<ResetLocalAssistantSessionFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
