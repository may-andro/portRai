import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/reset_remote_assistant_session_use_case.dart';
import 'package:use_case/use_case.dart';

class MockResetRemoteAssistantSessionUseCase extends Mock
    implements ResetRemoteAssistantSessionUseCase {}

extension MockResetRemoteAssistantSessionUseCaseStub
    on MockResetRemoteAssistantSessionUseCase {
  void stubCall(Either<RemoteAssistantFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
