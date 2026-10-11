import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:use_case/use_case.dart';

class MockAskPortfolioQuestionUseCase extends Mock
    implements AskPortfolioQuestionUseCase {}

extension MockAskPortfolioQuestionUseCaseStub
    on MockAskPortfolioQuestionUseCase {
  void stubCall({
    required AskPortfolioQuestionParams params,
    required Either<AssistantFailure, AssistantResponseEntity> result,
  }) {
    when(() => this(params)).thenAnswer((_) => result);
  }
}
