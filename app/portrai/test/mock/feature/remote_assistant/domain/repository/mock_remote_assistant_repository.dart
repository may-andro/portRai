import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/remote_assistant_repository.dart';

class MockRemoteAssistantRepository extends Mock
    implements RemoteAssistantRepository {}

class FakeAssistantMessageList extends Fake
    implements List<AssistantMessageEntity> {}

extension MockRemoteAssistantRepositoryStub on MockRemoteAssistantRepository {
  void stubResetSession() {
    when(() => resetSession()).thenAnswer((_) async {});
  }

  void stubResetSessionError(Object error) {
    when(() => resetSession()).thenThrow(error);
  }

  void stubAnswer() {
    when(
      () => answer(
        question: any(named: 'question'),
        portfolioContext: any(named: 'portfolioContext'),
        history: any(named: 'history'),
        onDelta: any(named: 'onDelta'),
        systemPrompt: any(named: 'systemPrompt'),
      ),
    ).thenAnswer((invocation) async {
      final callback =
          invocation.namedArguments[#onDelta] as void Function(String);
      callback('response delta');
    });
  }

  void stubAnswerError(Object error) {
    when(
      () => answer(
        question: any(named: 'question'),
        portfolioContext: any(named: 'portfolioContext'),
        history: any(named: 'history'),
        onDelta: any(named: 'onDelta'),
        systemPrompt: any(named: 'systemPrompt'),
      ),
    ).thenThrow(error);
  }
}
