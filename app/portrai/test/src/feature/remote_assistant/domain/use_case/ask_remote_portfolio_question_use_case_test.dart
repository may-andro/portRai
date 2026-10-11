import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/remote_assistant/domain/repository/mock_remote_assistant_repository.dart';
import '../../../../../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';

void _ignoreDelta(String _) {}

AskRemotePortfolioQuestionUseCase _createAskUseCase(
  MockRemoteAssistantRepository repository, {
  bool platformSupported = true,
}) => AskRemotePortfolioQuestionUseCase(
  repository,
  MockIsRemoteAssistantSupportedUseCase()..stubCall(Right(platformSupported)),
);

AssistantMessageEntity _message(String text, {required bool isUser}) =>
    AssistantMessageEntity(
      content: AssistantTextResponseEntity(text: text),
      isUser: isUser,
    );

void main() {
  test('should expose history limits when using the public limits alias', () {
    expect(RemoteAssistantLimits.maxHistoryMessages, 12);
    expect(RemoteAssistantLimits.maxHistoryCharacters, 24000);
  });

  setUp(() {
    registerFallbackValue(FakeAssistantMessageList());
    registerFallbackValue((String _) {});
  });

  test(
    'should stream deltas and return no response value when completed',
    () async {
      final repository = MockRemoteAssistantRepository()..stubAnswer();
      final received = <String>[];
      final params = AskRemotePortfolioQuestionParams(
        question: 'What projects use Flutter?',
        portfolioContext: 'Project portfolio',
        history: const [],
        onDelta: received.add,
      );

      final result = await _createAskUseCase(repository)(params);

      expect(result.isRight, isTrue);
      expect(received, ['response delta']);
      verify(
        () => repository.answer(
          question: params.question,
          portfolioContext: params.portfolioContext,
          history: any(named: 'history'),
          onDelta: params.onDelta,
        ),
      ).called(1);
    },
  );

  test(
    'should map a quota exception when repository rejects a request',
    () async {
      final repository = MockRemoteAssistantRepository()
        ..stubAnswerError(
          const AiQuotaExceededException('raw response', StackTrace.empty),
        );
      const params = AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Context',
        history: [],
        onDelta: _ignoreDelta,
      );

      final result = await _createAskUseCase(repository)(params);

      expect(result.isLeft, isTrue);
      expect(result.left, isA<RemoteAssistantQuotaFailure>());
    },
  );

  test('should reject a question over 2000 characters when called', () async {
    final repository = MockRemoteAssistantRepository();
    final result = await _createAskUseCase(repository)(
      AskRemotePortfolioQuestionParams(
        question: 'q' * 2001,
        portfolioContext: 'Context',
        history: const [],
        onDelta: _ignoreDelta,
      ),
    );

    expect(result.isLeft, isTrue);
    expect(result.left, isA<RemoteAssistantInvalidInputFailure>());
    verifyNever(
      () => repository.answer(
        question: any(named: 'question'),
        portfolioContext: any(named: 'portfolioContext'),
        history: any(named: 'history'),
        onDelta: any(named: 'onDelta'),
      ),
    );
  });

  test(
    'should reject portfolio context over 100000 characters when called',
    () async {
      final repository = MockRemoteAssistantRepository();
      final result = await _createAskUseCase(repository)(
        AskRemotePortfolioQuestionParams(
          question: 'Question',
          portfolioContext:
              'c' *
              (RemoteAssistantRequestLimits.maxPortfolioContextCharacters + 1),
          history: const [],
          onDelta: _ignoreDelta,
        ),
      );

      expect(result.isLeft, isTrue);
      expect(result.left, isA<RemoteAssistantInvalidInputFailure>());
    },
  );

  test('should reject more than 12 history messages when called', () async {
    final repository = MockRemoteAssistantRepository();
    final result = await _createAskUseCase(repository)(
      AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Context',
        history: List.generate(
          13,
          (index) => _message('Message $index', isUser: index.isEven),
        ),
        onDelta: _ignoreDelta,
      ),
    );

    expect(result.isLeft, isTrue);
    expect(result.left, isA<RemoteAssistantInvalidInputFailure>());
  });

  test('should reject history over 24000 characters when called', () async {
    final repository = MockRemoteAssistantRepository();
    final result = await _createAskUseCase(repository)(
      AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Context',
        history: [_message('h' * 24001, isUser: true)],
        onDelta: _ignoreDelta,
      ),
    );

    expect(result.isLeft, isTrue);
    expect(result.left, isA<RemoteAssistantInvalidInputFailure>());
  });

  test(
    'should reject empty history content when a completed message has no text',
    () async {
      final repository = MockRemoteAssistantRepository();
      final result = await _createAskUseCase(repository)(
        AskRemotePortfolioQuestionParams(
          question: 'Question',
          portfolioContext: 'Context',
          history: [_message('', isUser: false)],
          onDelta: _ignoreDelta,
        ),
      );
      expect(result.isLeft, isTrue);
      expect(result.left, isA<RemoteAssistantInvalidInputFailure>());
      verifyZeroInteractions(repository);
    },
  );

  test(
    'should reject direct requests when the current platform is unsupported',
    () async {
      final repository = MockRemoteAssistantRepository();
      final result =
          await _createAskUseCase(repository, platformSupported: false)(
            const AskRemotePortfolioQuestionParams(
              question: 'Question',
              portfolioContext: 'Context',
              history: [],
              onDelta: _ignoreDelta,
            ),
          );

      expect(result.isLeft, isTrue);
      expect(result.left, isA<RemoteAssistantUnavailableFailure>());
      verifyZeroInteractions(repository);
    },
  );

  test(
    'should keep prompt and response data out of parameter logging when inspected',
    () {
      const privateText = 'private prompt and generated response';
      final params = AskRemotePortfolioQuestionParams(
        question: privateText,
        portfolioContext: privateText,
        history: [_message(privateText, isUser: false)],
        onDelta: (delta) {},
      );

      expect(params.toString(), isNot(contains(privateText)));
      expect(
        params.toString(),
        'AskRemotePortfolioQuestionParams(metadata only)',
      );
    },
  );
}
