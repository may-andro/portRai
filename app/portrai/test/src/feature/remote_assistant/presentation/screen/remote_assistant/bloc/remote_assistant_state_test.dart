import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

void main() {
  test('should omit conversation content when state and events are logged', () {
    const state = RemoteAssistantState(
      portfolioContext: 'Private context',
      partialAnswer: 'Private generated text',
      messages: [
        AssistantMessageEntity(
          content: AssistantTextResponseEntity(text: 'Private question'),
          isUser: true,
        ),
      ],
    );
    expect(state.toString(), isNot(contains('Private')));
    expect(
      const SendRemoteAssistantQuestionClickEvent(
        'Private question',
      ).toString(),
      isNot(contains('Private')),
    );
  });

  test('should show provisional content separately when text is streaming', () {
    const state = RemoteAssistantState(partialAnswer: 'Partial');
    expect(state.messages, isEmpty);
    expect(
      state.visibleMessages.single.content,
      const AssistantTextResponseEntity(text: 'Partial'),
    );
  });

  test(
    'should clear sensitive state when disable clears context and failure',
    () {
      const state = RemoteAssistantState(
        portfolioContext: 'Context',
        failure: UnknownFailure(),
      );
      final cleared = state.copyWith(clearContext: true, clearFailure: true);
      expect(cleared.portfolioContext, isNull);
      expect(cleared.failure, isNull);
    },
  );
}
