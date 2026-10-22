import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/ask_local_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';

import '../../../../../mock/feature/local_assistant/domain/repository/mock_local_assistant_repository.dart';
import '../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';

void main() {
  const params = AskLocalPortfolioQuestionParams(
    question: 'Which projects use Flutter?',
    portfolioContext: 'Verified portfolio context',
  );

  MockIsLocalAssistantSupportedUseCase supportedCase() =>
      MockIsLocalAssistantSupportedUseCase()..stubCall(true);

  test(
    'should return a typed text response when the repository answers',
    () async {
      final repository = MockLocalAssistantRepository()
        ..stubAnswer(
          question: params.question,
          portfolioContext: params.portfolioContext,
          answer: 'These projects use Flutter.',
        );

      final result = await AskLocalPortfolioQuestionUseCase(
        repository,
        supportedCase(),
      )(params);

      expect(result.isRight, isTrue);
      expect(
        result.right,
        const AssistantTextResponseEntity(text: 'These projects use Flutter.'),
      );
      verify(
        () => repository.answer(
          question: params.question,
          portfolioContext: params.portfolioContext,
          onPartialAnswer: any(named: 'onPartialAnswer'),
        ),
      ).called(1);
    },
  );

  test('should pass partial answers on when the repository streams', () async {
    final partialAnswers = <String>[];
    final repository = MockLocalAssistantRepository();
    when(
      () => repository.answer(
        question: params.question,
        portfolioContext: params.portfolioContext,
        onPartialAnswer: any(named: 'onPartialAnswer'),
      ),
    ).thenAnswer((invocation) async {
      final onPartialAnswer =
          invocation.namedArguments[#onPartialAnswer] as void Function(String)?;
      onPartialAnswer?.call('These');
      return 'These projects';
    });

    await AskLocalPortfolioQuestionUseCase(repository, supportedCase())(
      AskLocalPortfolioQuestionParams(
        question: params.question,
        portfolioContext: params.portfolioContext,
        onPartialAnswer: partialAnswers.add,
      ),
    );

    expect(partialAnswers, ['These']);
  });

  test('should preserve the cause when the repository fails', () async {
    final error = StateError('Model unavailable');
    final repository = MockLocalAssistantRepository()
      ..stubAnswerError(
        question: params.question,
        portfolioContext: params.portfolioContext,
        error: error,
      );

    final result = await AskLocalPortfolioQuestionUseCase(
      repository,
      supportedCase(),
    )(params);

    expect(result.isLeft, isTrue);
    expect(result.left, isA<UnknownLocalAssistantFailure>());
    expect(result.left.cause, same(error));
  });

  test(
    'should map a typed availability exception when the repository blocks access',
    () async {
      final repository = MockLocalAssistantRepository()
        ..stubAnswerError(
          question: params.question,
          portfolioContext: params.portfolioContext,
          error: const LocalAssistantUnavailableException(),
        );

      final result = await AskLocalPortfolioQuestionUseCase(
        repository,
        supportedCase(),
      )(params);
      expect(result.left, isA<UnavailableLocalAssistantFailure>());
    },
  );

  test(
    'should map a busy exception when previous native work is still finishing',
    () async {
      final repository = MockLocalAssistantRepository()
        ..stubAnswerError(
          question: params.question,
          portfolioContext: params.portfolioContext,
          error: const LocalAssistantBusyException(),
        );
      final result = await AskLocalPortfolioQuestionUseCase(
        repository,
        supportedCase(),
      )(params);
      expect(result.left, isA<BusyLocalAssistantFailure>());
    },
  );

  test(
    'should reject questions without calling the repository when unsupported',
    () async {
      final repository = MockLocalAssistantRepository();
      final support = MockIsLocalAssistantSupportedUseCase()..stubCall(false);

      final result = await AskLocalPortfolioQuestionUseCase(
        repository,
        support,
      )(params);

      expect(result.left, isA<UnavailableLocalAssistantFailure>());
      verifyNever(
        () => repository.answer(
          question: params.question,
          portfolioContext: params.portfolioContext,
          onPartialAnswer: any(named: 'onPartialAnswer'),
        ),
      );
    },
  );
}
