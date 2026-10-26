import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/ai_rate_limit/domain/use_case/mock_consume_ai_request_quota_use_case.dart';
import '../../../../../mock/feature/remote_assistant/domain/repository/mock_remote_assistant_repository.dart';
import '../../../../../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';

void _ignoreDelta(String _) {}

AskRemotePortfolioQuestionUseCase _createAskUseCase(
  MockRemoteAssistantRepository repository, {
  bool platformSupported = true,
  Either<ConsumeAiRequestQuotaFailure, void> consumeAiRequestQuotaEither =
      const Right(null),
}) => AskRemotePortfolioQuestionUseCase(
  repository,
  MockIsRemoteAssistantSupportedUseCase()..stubCall(Right(platformSupported)),
  MockConsumeAiRequestQuotaUseCase()..stubCall(consumeAiRequestQuotaEither),
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
      expect(result.left, isA<AskRemotePortfolioQuestionQuotaFailure>());
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
    expect(result.left, isA<AskRemotePortfolioQuestionInvalidInputFailure>());
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
      expect(result.left, isA<AskRemotePortfolioQuestionInvalidInputFailure>());
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
    expect(result.left, isA<AskRemotePortfolioQuestionInvalidInputFailure>());
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
    expect(result.left, isA<AskRemotePortfolioQuestionInvalidInputFailure>());
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
      expect(result.left, isA<AskRemotePortfolioQuestionInvalidInputFailure>());
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
      expect(result.left, isA<AskRemotePortfolioQuestionUnavailableFailure>());
      verifyZeroInteractions(repository);
    },
  );

  test('should forward bounded framework instructions when supplied', () async {
    final repository = MockRemoteAssistantRepository()..stubAnswer();
    final prompt = 'p' * RemoteAssistantRequestLimits.maxSystemPromptCharacters;
    final result = await _createAskUseCase(repository)(
      AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Context',
        history: const [],
        onDelta: _ignoreDelta,
        systemPrompt: prompt,
      ),
    );
    expect(result.isRight, isTrue);
    verify(
      () => repository.answer(
        question: 'Question',
        portfolioContext: 'Context',
        history: any(named: 'history'),
        onDelta: _ignoreDelta,
        systemPrompt: prompt,
      ),
    ).called(1);
  });

  test(
    'should reject oversized framework instructions when supplied',
    () async {
      final repository = MockRemoteAssistantRepository();
      final result = await _createAskUseCase(repository)(
        AskRemotePortfolioQuestionParams(
          question: 'Question',
          portfolioContext: 'Context',
          history: const [],
          onDelta: _ignoreDelta,
          systemPrompt:
              'p' *
              (RemoteAssistantRequestLimits.maxSystemPromptCharacters + 1),
        ),
      );
      expect(result.left, isA<AskRemotePortfolioQuestionInvalidInputFailure>());
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
        systemPrompt: privateText,
      );

      expect(params.toString(), isNot(contains(privateText)));
      expect(
        params.toString(),
        'AskRemotePortfolioQuestionParams(metadata only)',
      );
    },
  );

  test(
    'should return a quota failure without asking when the AI budget is used up',
    () async {
      final repository = MockRemoteAssistantRepository()..stubAnswer();

      final askRemotePortfolioQuestionEither =
          await _createAskUseCase(
            repository,
            consumeAiRequestQuotaEither: const Left(
              AiRequestQuotaExceededFailure(),
            ),
          )(
            const AskRemotePortfolioQuestionParams(
              question: 'What projects use Flutter?',
              portfolioContext: 'Project portfolio',
              history: [],
              onDelta: _ignoreDelta,
            ),
          );

      expect(
        askRemotePortfolioQuestionEither.left,
        isA<AskRemotePortfolioQuestionQuotaFailure>(),
      );
      verifyNever(
        () => repository.answer(
          question: any(named: 'question'),
          portfolioContext: any(named: 'portfolioContext'),
          history: any(named: 'history'),
          onDelta: any(named: 'onDelta'),
          systemPrompt: any(named: 'systemPrompt'),
        ),
      );
    },
  );

  test(
    'should still ask the question when the AI request log cannot be read',
    () async {
      final repository = MockRemoteAssistantRepository()..stubAnswer();

      final askRemotePortfolioQuestionEither =
          await _createAskUseCase(
            repository,
            consumeAiRequestQuotaEither: const Left(
              AiRequestQuotaCacheFailure(),
            ),
          )(
            const AskRemotePortfolioQuestionParams(
              question: 'What projects use Flutter?',
              portfolioContext: 'Project portfolio',
              history: [],
              onDelta: _ignoreDelta,
            ),
          );

      expect(askRemotePortfolioQuestionEither.isRight, isTrue);
    },
  );
  group('mapErrorToFailure', () {
    Future<AskRemotePortfolioQuestionFailure> askFailing(Object error) async {
      final repository = MockRemoteAssistantRepository()
        ..stubAnswerError(error);
      final askRemotePortfolioQuestionEither =
          await _createAskUseCase(repository)(
            const AskRemotePortfolioQuestionParams(
              question: 'secret prompt',
              portfolioContext: 'secret context',
              history: [],
              onDelta: _ignoreDelta,
            ),
          );
      expect(askRemotePortfolioQuestionEither.isLeft, isTrue);
      return askRemotePortfolioQuestionEither.left;
    }

    final cases = <(Object, Matcher)>[
      (
        const AiQuotaExceededException('secret server body', StackTrace.empty),
        isA<AskRemotePortfolioQuestionQuotaFailure>(),
      ),
      (
        const AiNetworkException('secret server body', StackTrace.empty),
        isA<AskRemotePortfolioQuestionNetworkFailure>(),
      ),
      (
        const AiTimeoutException('secret server body', StackTrace.empty),
        isA<AskRemotePortfolioQuestionTimeoutFailure>(),
      ),
      (
        const AiServerException('secret server body', StackTrace.empty),
        isA<AskRemotePortfolioQuestionUnknownFailure>(),
      ),
      (
        const AiConfigurationException('secret server body', StackTrace.empty),
        isA<AskRemotePortfolioQuestionConfigurationFailure>(),
      ),
      (
        const AiUnsupportedLocationException(
          'secret server body',
          StackTrace.empty,
        ),
        isA<AskRemotePortfolioQuestionConfigurationFailure>(),
      ),
      (
        const AiBlockedResponseException(
          'secret generated text',
          StackTrace.empty,
        ),
        isA<AskRemotePortfolioQuestionBlockedFailure>(),
      ),
      (
        const AiInvalidInputException('secret prompt', StackTrace.empty),
        isA<AskRemotePortfolioQuestionInvalidInputFailure>(),
      ),
      (
        const AiIncompleteResponseException(
          'secret generated text',
          StackTrace.empty,
        ),
        isA<AskRemotePortfolioQuestionIncompleteFailure>(),
      ),
      (
        const AiEmptyResponseException(
          'secret generated text',
          StackTrace.empty,
        ),
        isA<AskRemotePortfolioQuestionIncompleteFailure>(),
      ),
      (
        const AiSdkException('secret server body', StackTrace.empty),
        isA<AskRemotePortfolioQuestionUnknownFailure>(),
      ),
      (
        const RemoteAssistantClosedException(),
        isA<AskRemotePortfolioQuestionUnavailableFailure>(),
      ),
      (
        const RemoteAssistantConcurrentRequestException(),
        isA<AskRemotePortfolioQuestionUnavailableFailure>(),
      ),
      (
        const RemoteAssistantFlagException(),
        isA<AskRemotePortfolioQuestionConfigurationFailure>(),
      ),
      (
        const RemoteAssistantUnavailableException(),
        isA<AskRemotePortfolioQuestionUnavailableFailure>(),
      ),
      (
        const RemoteAssistantInvalidInputException(),
        isA<AskRemotePortfolioQuestionInvalidInputFailure>(),
      ),
      (
        const RemoteAssistantTimeoutException(),
        isA<AskRemotePortfolioQuestionTimeoutFailure>(),
      ),
      (
        const RemoteAssistantCancelledException(),
        isA<AskRemotePortfolioQuestionUnavailableFailure>(),
      ),
      (
        const RemoteAssistantCallbackException(),
        isA<AskRemotePortfolioQuestionUnknownFailure>(),
      ),
      (
        const RemoteAssistantIncompleteException(),
        isA<AskRemotePortfolioQuestionIncompleteFailure>(),
      ),
      (
        const RemoteAssistantResponseLimitException(),
        isA<AskRemotePortfolioQuestionIncompleteFailure>(),
      ),
    ];

    for (final (error, expected) in cases) {
      test(
        'should map ${error.runtimeType} without sensitive causes when asking fails',
        () async {
          final failure = await askFailing(error);
          expect(failure, expected);
          expect(failure.cause, error is AiException ? same(error) : isNull);
          expect(
            failure.serviceMessage,
            error is AiException ? error.serviceMessage : null,
          );
          expect(failure.toString(), isNot(contains('secret')));
        },
      );
    }

    test(
      'should treat unexpected failure objects as unknown when asking fails',
      () async {
        const error = AskRemotePortfolioQuestionQuotaFailure(
          cause: 'secret server body',
        );
        final failure = await askFailing(error);
        expect(failure, isA<AskRemotePortfolioQuestionUnknownFailure>());
        expect(failure.cause, isNull);
        expect(failure, isNot(same(error)));
      },
    );

    test(
      'should drop the cause when an unrecognized exception makes asking fail',
      () async {
        final failure = await askFailing(StateError('secret server body'));
        expect(failure, isA<AskRemotePortfolioQuestionUnknownFailure>());
        expect(failure.cause, isNull);
        expect(failure.toString(), isNot(contains('secret')));
      },
    );

    for (final error in <AiException>[
      const AiServerException(
        'secret raw SDK body',
        StackTrace.empty,
        serviceMessage:
            'Your credits are depleted. Enable billing to continue.',
      ),
      const AiQuotaExceededException(
        'secret raw SDK body',
        StackTrace.empty,
        serviceMessage: 'Quota exceeded. Try again later.',
      ),
      const AiConfigurationException(
        'secret raw SDK body',
        StackTrace.empty,
        serviceMessage: 'Enable the Gemini API in the console.',
      ),
      const AiUnsupportedLocationException(
        'secret raw SDK body',
        StackTrace.empty,
        serviceMessage: 'User location is not supported for the API use.',
      ),
    ]) {
      test(
        'should preserve service details without logging them when ${error.runtimeType} makes asking fail',
        () async {
          final failure = await askFailing(error);
          expect(failure.cause, same(error));
          expect(failure.serviceMessage, error.serviceMessage);
          expect(failure.toString(), isNot(contains(error.serviceMessage)));
          expect(failure.toString(), isNot(contains('secret')));
          expect(failure.props, [error]);
        },
      );
    }
  });
}
