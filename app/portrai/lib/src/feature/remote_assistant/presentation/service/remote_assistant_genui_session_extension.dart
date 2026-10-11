import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

extension RemoteAssistantGenuiSessionExtension on AssistantGenuiSession {
  /// Sends a known text question and authoritative context, not raw GenUI
  /// messages or UI interaction parts, through the portfolio use case.
  Future<Either<RemoteAssistantFailure, void>> sendPortfolioQuestion({
    required AskRemotePortfolioQuestionUseCase
    askRemotePortfolioQuestionUseCase,
    required String question,
    required String portfolioContext,
    required List<AssistantMessageEntity> history,
  }) => send(
    ChatMessage.user(question),
    generate: (_, systemPrompt, onDelta) async =>
        await askRemotePortfolioQuestionUseCase(
          AskRemotePortfolioQuestionParams(
            question: question,
            portfolioContext: portfolioContext,
            history: history,
            onDelta: onDelta,
            systemPrompt: systemPrompt,
          ),
        ),
  );
}
