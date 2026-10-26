import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/is_remote_assistant_supported_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class AskRemotePortfolioQuestionFailure extends BasicFailure {
  const AskRemotePortfolioQuestionFailure({super.cause, this.serviceMessage});

  /// Optional backend error details supplement, never replace, localization.
  /// Excluded from inherited failure logging and equality properties.
  final String? serviceMessage;
}

@Localizable('errorRemoteAssistantUnavailable')
class AskRemotePortfolioQuestionUnavailableFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionUnavailableFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantNetwork')
class AskRemotePortfolioQuestionNetworkFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionNetworkFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantTimeout')
class AskRemotePortfolioQuestionTimeoutFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionTimeoutFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantQuota')
class AskRemotePortfolioQuestionQuotaFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionQuotaFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantConfiguration')
class AskRemotePortfolioQuestionConfigurationFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionConfigurationFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantBlocked')
class AskRemotePortfolioQuestionBlockedFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionBlockedFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantInvalidInput')
class AskRemotePortfolioQuestionInvalidInputFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionInvalidInputFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantIncomplete')
class AskRemotePortfolioQuestionIncompleteFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionIncompleteFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantUnknown')
class AskRemotePortfolioQuestionUnknownFailure
    extends AskRemotePortfolioQuestionFailure {
  const AskRemotePortfolioQuestionUnknownFailure({
    super.cause,
    super.serviceMessage,
  });
}

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
  /// Default when the app config sets no `aiAssistantModel`.
  static const model = 'gemini-3.8-flash';
  static const maxOutputTokens = 4096;
  static const temperature = 0.3;
  static const maxQuestionCharacters = 2000;
  // The official catalog prompt with every item registered is ~50k; leave
  // headroom for response-style instructions and future items.
  static const maxSystemPromptCharacters = 80000;
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
          AskRemotePortfolioQuestionFailure
        > {
  AskRemotePortfolioQuestionUseCase(
    this._repository,
    this._isRemoteAssistantSupportedUseCase,
    this._consumeAiRequestQuotaUseCase,
  );

  final RemoteAssistantRepository _repository;
  final IsRemoteAssistantSupportedUseCase _isRemoteAssistantSupportedUseCase;
  final ConsumeAiRequestQuotaUseCase _consumeAiRequestQuotaUseCase;

  @protected
  @override
  Future<Either<AskRemotePortfolioQuestionFailure, void>> execute(
    AskRemotePortfolioQuestionParams params,
  ) async {
    final platformSupport = await _isRemoteAssistantSupportedUseCase();
    if (platformSupport.isLeft || !platformSupport.right) {
      return const Left(AskRemotePortfolioQuestionUnavailableFailure());
    }
    if (!_isValid(params)) {
      return const Left(AskRemotePortfolioQuestionInvalidInputFailure());
    }
    final consumeAiRequestQuotaEither = await _consumeAiRequestQuotaUseCase();
    // Only a used-up budget blocks the question; an unreadable request log
    // does not, and the backend quota still applies.
    if (consumeAiRequestQuotaEither.isLeft &&
        consumeAiRequestQuotaEither.left is AiRequestQuotaExceededFailure) {
      return Left(
        AskRemotePortfolioQuestionQuotaFailure(
          cause: consumeAiRequestQuotaEither.left,
        ),
      );
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
  AskRemotePortfolioQuestionFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    RemoteAssistantUnavailableException() ||
    RemoteAssistantCancelledException() ||
    RemoteAssistantClosedException() ||
    RemoteAssistantConcurrentRequestException() =>
      const AskRemotePortfolioQuestionUnavailableFailure(),
    AiNetworkException(:final serviceMessage) =>
      AskRemotePortfolioQuestionNetworkFailure(
        cause: error,
        serviceMessage: serviceMessage,
      ),
    AiServerException(:final serviceMessage) =>
      AskRemotePortfolioQuestionUnknownFailure(
        cause: error,
        serviceMessage: serviceMessage,
      ),
    AiTimeoutException() => AskRemotePortfolioQuestionTimeoutFailure(
      cause: error,
    ),
    RemoteAssistantTimeoutException() =>
      const AskRemotePortfolioQuestionTimeoutFailure(),
    AiQuotaExceededException(:final serviceMessage) =>
      AskRemotePortfolioQuestionQuotaFailure(
        cause: error,
        serviceMessage: serviceMessage,
      ),
    AiConfigurationException(:final serviceMessage) ||
    AiUnsupportedLocationException(
      :final serviceMessage,
    ) => AskRemotePortfolioQuestionConfigurationFailure(
      cause: error,
      serviceMessage: serviceMessage,
    ),
    RemoteAssistantFlagException() =>
      const AskRemotePortfolioQuestionConfigurationFailure(),
    AiBlockedResponseException() => AskRemotePortfolioQuestionBlockedFailure(
      cause: error,
    ),
    AiInvalidInputException() => AskRemotePortfolioQuestionInvalidInputFailure(
      cause: error,
    ),
    RemoteAssistantInvalidInputException() =>
      const AskRemotePortfolioQuestionInvalidInputFailure(),
    AiEmptyResponseException() || AiIncompleteResponseException() =>
      AskRemotePortfolioQuestionIncompleteFailure(cause: error),
    RemoteAssistantIncompleteException() ||
    RemoteAssistantResponseLimitException() =>
      const AskRemotePortfolioQuestionIncompleteFailure(),
    RemoteAssistantCallbackException() =>
      const AskRemotePortfolioQuestionUnknownFailure(),
    AiSdkException() => AskRemotePortfolioQuestionUnknownFailure(cause: error),
    _ => const AskRemotePortfolioQuestionUnknownFailure(),
  };
}
