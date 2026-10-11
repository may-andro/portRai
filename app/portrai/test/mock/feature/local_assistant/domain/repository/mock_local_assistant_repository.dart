import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/local_assistant_repository.dart';

class MockLocalAssistantRepository extends Mock
    implements LocalAssistantRepository {}

extension MockLocalAssistantRepositoryStub on MockLocalAssistantRepository {
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
