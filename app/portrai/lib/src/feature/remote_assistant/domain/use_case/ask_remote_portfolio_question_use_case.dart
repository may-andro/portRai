import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/is_remote_assistant_supported_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class AskRemotePortfolioQuestionParams {
  const AskRemotePortfolioQuestionParams({
    required this.question,
    required this.portfolioContext,
    required this.history,
    required this.onDelta,
    this.systemPrompt,
  });

  final String question;
  final String portfolioContext;
  final List<AssistantMessageEntity> history;
  final void Function(String delta) onDelta;

  /// Trusted presentation-framework instructions, never user-supplied data.
  /// Supplementary only: repository portfolio grounding remains authoritative.
  final String? systemPrompt;

  @override
  String toString() => 'AskRemotePortfolioQuestionParams(metadata only)';
}

abstract final class RemoteAssistantRequestLimits {
  static const model = 'gemini-3.8-flash';
  static const maxOutputTokens = 1024;
  static const temperature = 0.3;
  static const maxQuestionCharacters = 2000;
  // The current official catalog prompt is ~21k; leave bounded schema headroom.
  static const maxSystemPromptCharacters = 50000;
  // Preserve the complete shared JSON, including overview/digest and details.
  // Bound per-request input cost; overflow is rejected, never sliced.
  static const maxPortfolioContextCharacters = 100000;
  static const maxHistoryMessages = 12;
  static const maxHistoryCharacters = 24000;
  static const maxResponseCharacters = 12000;
  static const requestTimeout = Duration(seconds: 60);
}

typedef RemoteAssistantLimits = RemoteAssistantRequestLimits;

@register
class AskRemotePortfolioQuestionUseCase
    extends
        BaseUseCase<
          void,
          AskRemotePortfolioQuestionParams,
          RemoteAssistantFailure
        > {
  AskRemotePortfolioQuestionUseCase(
    this._repository,
    this._isRemoteAssistantSupportedUseCase,
  );

  final RemoteAssistantRepository _repository;
  final IsRemoteAssistantSupportedUseCase _isRemoteAssistantSupportedUseCase;

  @protected
  @override
  Future<Either<RemoteAssistantFailure, void>> execute(
    AskRemotePortfolioQuestionParams params,
  ) async {
    final platformSupport = await _isRemoteAssistantSupportedUseCase();
    if (platformSupport.isLeft || !platformSupport.right) {
      return const Left(RemoteAssistantUnavailableFailure());
    }
    if (!_isValid(params)) {
      return const Left(RemoteAssistantInvalidInputFailure());
    }
    await _repository.answer(
      question: params.question,
      portfolioContext: params.portfolioContext,
      history: List.unmodifiable(params.history),
      onDelta: params.onDelta,
      systemPrompt: params.systemPrompt,
    );
    return const Right(null);
  }

  static bool _isValid(AskRemotePortfolioQuestionParams params) {
    if ((params.systemPrompt?.length ?? 0) >
            RemoteAssistantRequestLimits.maxSystemPromptCharacters ||
        params.question.trim().isEmpty ||
        params.question.length >
            RemoteAssistantRequestLimits.maxQuestionCharacters ||
        params.portfolioContext.length >
            RemoteAssistantRequestLimits.maxPortfolioContextCharacters ||
        params.history.length >
            RemoteAssistantRequestLimits.maxHistoryMessages) {
      return false;
    }

    var historyCharacters = 0;
    for (final message in params.history) {
      final content = message.content;
      if (content is! AssistantTextResponseEntity || content.text.isEmpty) {
        return false;
      }
      historyCharacters += content.text.length;
      if (historyCharacters >
          RemoteAssistantRequestLimits.maxHistoryCharacters) {
        return false;
      }
    }
    return true;
  }

  @protected
  @override
  RemoteAssistantFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => error.toRemoteAssistantFailure();
}
