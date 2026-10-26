import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:use_case/use_case.dart';

class MockAskRemotePortfolioQuestionUseCase extends Mock
    implements AskRemotePortfolioQuestionUseCase {}

extension MockAskRemotePortfolioQuestionUseCaseStub
    on MockAskRemotePortfolioQuestionUseCase {
  void stubCall({
    required AskRemotePortfolioQuestionParams params,
    required Either<AskRemotePortfolioQuestionFailure, void> result,
    List<String> deltas = const [],
  }) {
    when(() => this(params)).thenAnswer((_) {
      for (final delta in deltas) {
        params.onDelta(delta);
      }
      return Future.value(result);
    });
  }
}
