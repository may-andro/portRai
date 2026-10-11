import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/ask_local_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class MockAskLocalPortfolioQuestionUseCase extends Mock
    implements AskLocalPortfolioQuestionUseCase {}

extension MockAskLocalPortfolioQuestionUseCaseStub
    on MockAskLocalPortfolioQuestionUseCase {
  void stubCall({
    required AskLocalPortfolioQuestionParams params,
    required Either<LocalAssistantFailure, AssistantResponseEntity> result,
  }) {
    when(() => this(params)).thenAnswer((_) => result);
  }
}
