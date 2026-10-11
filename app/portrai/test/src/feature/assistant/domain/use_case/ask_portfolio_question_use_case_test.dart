import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';

import '../../../../../mock/feature/assistant/domain/repository/mock_assistant_repository.dart';

void main() {
  const params = AskPortfolioQuestionParams(
    question: 'Which projects use Flutter?',
    portfolioContext: 'Verified portfolio context',
  );

  test(
    'should return a typed text response when the repository answers',
    () async {
      final repository = MockAssistantRepository()
        ..stubAnswer(
          question: params.question,
          portfolioContext: params.portfolioContext,
          answer: 'These projects use Flutter.',
        );

      final result = await AskPortfolioQuestionUseCase(repository)(params);

      expect(result.isRight, isTrue);
      expect(
        result.right,
        const AssistantTextResponseEntity(text: 'These projects use Flutter.'),
      );
      verify(
        () => repository.answer(
          question: params.question,
          portfolioContext: params.portfolioContext,
        ),
      ).called(1);
    },
  );

  test('should preserve the cause when the repository fails', () async {
    final error = StateError('Model unavailable');
    final repository = MockAssistantRepository()
      ..stubAnswerError(
        question: params.question,
        portfolioContext: params.portfolioContext,
        error: error,
      );

    final result = await AskPortfolioQuestionUseCase(repository)(params);

    expect(result.isLeft, isTrue);
    expect(result.left, isA<UnknownAssistantFailure>());
    expect(result.left.cause, same(error));
  });
}
