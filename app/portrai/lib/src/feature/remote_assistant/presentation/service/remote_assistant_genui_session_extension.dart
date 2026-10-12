import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

const _responseStyleInstruction =
    'Response style: answer in a single surface that contains the entire '
    'answer, and do not write any text outside the surface. Use only plain '
    'text: no markdown, no asterisks, no numbered or bulleted syntax; use '
    'one DSText per item or fact inside a DSCard instead. Never repeat the '
    'surface content as text. Put every A2UI message in its own separate '
    '```json code block, never two messages in one block.';

extension RemoteAssistantGenuiSessionExtension on AssistantGenuiSession {
  /// Sends a known text question and authoritative context, not raw GenUI
  /// messages or UI interaction parts, through the portfolio use case.
  Future<Either<RemoteAssistantFailure, void>> sendPortfolioQuestion({
    required AskRemotePortfolioQuestionUseCase
    askRemotePortfolioQuestionUseCase,
    required String question,
    required String portfolioContext,
    required List<AssistantMessageEntity> history,
    void Function(String text)? onText,
    void Function(SurfaceUpdate update)? onSurfaceUpdate,
  }) async {
    var hasText = false;
    try {
      final result = await send(
        ChatMessage.user(question),
        onText: (text) {
          if (text.trim().isNotEmpty) hasText = true;
          onText?.call(text);
        },
        onSurfaceUpdate: onSurfaceUpdate,
        generate: (_, systemPrompt, onDelta) async =>
            await askRemotePortfolioQuestionUseCase(
              AskRemotePortfolioQuestionParams(
                question: question,
                portfolioContext: portfolioContext,
                history: history,
                onDelta: onDelta,
                systemPrompt: '$systemPrompt\n\n$_responseStyleInstruction',
              ),
            ),
      );
      if (result.isLeft) return result;
      if (!hasText && activeSurfaceIds.isEmpty) {
        return const Left(RemoteAssistantIncompleteFailure());
      }
      return result;
    } on AssistantGenuiResponseException {
      return const Left(RemoteAssistantIncompleteFailure());
    } on AssistantGenuiTurnCancelledException {
      return const Left(RemoteAssistantIncompleteFailure());
    }
  }
}
