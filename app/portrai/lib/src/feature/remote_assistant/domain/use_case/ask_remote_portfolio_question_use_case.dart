import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class AskRemotePortfolioQuestionParams {
  const AskRemotePortfolioQuestionParams({
    required this.question,
    required this.portfolioContext,
    required this.history,
    required this.onDelta,
  });

  final String question;
  final String portfolioContext;
  final List<AssistantMessageEntity> history;
  final void Function(String delta) onDelta;

  @override
  String toString() => 'AskRemotePortfolioQuestionParams(metadata only)';
}

abstract final class RemoteAssistantRequestLimits {
  static const model = 'gemini-2.5-flash';
  static const maxOutputTokens = 1024;
  static const temperature = 0.3;
  static const maxQuestionCharacters = 2000;
  // Preserve the complete shared JSON, including overview/digest and details.
  // This fixed budget leaves ample room in Gemini 2.5 Flash's context window
  // while bounding per-request input cost; overflow is rejected, never sliced.
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
  AskRemotePortfolioQuestionUseCase(this._repository);

  final RemoteAssistantRepository _repository;

  @protected
  @override
  Future<Either<RemoteAssistantFailure, void>> execute(
    AskRemotePortfolioQuestionParams params,
  ) async {
    if (!_isValid(params)) {
      return const Left(RemoteAssistantInvalidInputFailure());
    }
    await _repository.answer(
      question: params.question,
      portfolioContext: params.portfolioContext,
      history: List.unmodifiable(params.history),
      onDelta: params.onDelta,
    );
    return const Right(null);
  }

  static bool _isValid(AskRemotePortfolioQuestionParams params) {
    if (params.question.trim().isEmpty ||
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
