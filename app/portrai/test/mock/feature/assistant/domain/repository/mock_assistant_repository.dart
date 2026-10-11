import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/domain/repository/assistant_repository.dart';

class MockAssistantRepository extends Mock implements AssistantRepository {}

extension MockAssistantRepositoryStub on MockAssistantRepository {
  void stubAnswer({
    required String question,
    required String portfolioContext,
    required String answer,
  }) {
    when(
      () => this.answer(question: question, portfolioContext: portfolioContext),
    ).thenAnswer((_) async => answer);
  }

  void stubAnswerError({
    required String question,
    required String portfolioContext,
    required Object error,
  }) {
    when(
      () => answer(question: question, portfolioContext: portfolioContext),
    ).thenThrow(error);
  }
}
