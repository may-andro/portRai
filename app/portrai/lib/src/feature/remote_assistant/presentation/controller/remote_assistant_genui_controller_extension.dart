import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

const _responseStyleInstruction =
    'Response style: answer in one surface that holds the entire answer, and '
    'write no text outside it. Never repeat surface content as text. Use plain '
    'text only: no markdown, asterisks or bullet characters. Pick the '
    'component that fits the data instead of plain text: DSMetric for a key '
    'number (for example years of experience), DSLabeledInfoRow for facts '
    'such as company, period or location, DSTag or DSInfoChip inside a DSWrap '
    'for skills and technologies, DSBulletList for several short points, '
    'DSExpandable for optional detail, DSTimeline for career or education '
    'history, DSSkillBars to compare skills by years, DSQuote for a '
    'testimonial copied exactly, '
    'DSStatGrid for two to four DSMetric side by side, DSCarousel for several cards, DSTabs to switch between groups, '
    'DSCallout for a highlighted note such as availability, '
    'DSText variants heading, title, body '
    'and caption for prose. Group with a DSColumn root; use a DSCard only '
    'around a distinct group, and never around a one-line answer. For a '
    'simple factual answer use a single DSText. Keep the answer concise. Put '
    'every A2UI message in its own separate ```json code block, never two '
    'messages in one block.';

const _imageInstruction =
    ' To show a picture use DSImage with a url copied exactly from the '
    'portfolio information (profile image, company logo, project image). Use '
    'avatar for a person, logo for a company and banner for a project. Never '
    'invent or alter a URL, and omit the image if none is available.';

const _linkInstruction =
    ' To let the user open a link use DSLinkButton with a url copied exactly '
    'from the portfolio information. Never invent or alter a URL.';

const _mapInstruction =
    ' To show where the person is based or has worked use DSMap with one '
    'place per location, with latitude and longitude copied exactly from the '
    'profile location or from experiences. Never invent coordinates.';

extension RemoteAssistantGenuiControllerExtension on AssistantGenuiController {
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
                systemPrompt:
                    '$systemPrompt\n\n$_responseStyleInstruction'
                    '${supportsImages ? _imageInstruction : ''}'
                    '${supportsLinks ? _linkInstruction : ''}'
                    '${supportsMaps ? _mapInstruction : ''}',
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
