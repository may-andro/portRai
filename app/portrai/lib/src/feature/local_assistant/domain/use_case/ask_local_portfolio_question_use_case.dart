import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class AskLocalPortfolioQuestionFailure extends BasicFailure {
  const AskLocalPortfolioQuestionFailure({super.cause});
}

@Localizable('assistantError')
class AskLocalPortfolioQuestionUnknownFailure
    extends AskLocalPortfolioQuestionFailure {
  const AskLocalPortfolioQuestionUnknownFailure({super.cause});
}

@Localizable('errorLocalAssistantUnavailable')
class AskLocalPortfolioQuestionUnavailableFailure
    extends AskLocalPortfolioQuestionFailure {
  const AskLocalPortfolioQuestionUnavailableFailure({super.cause});
}

@Localizable('errorLocalAssistantBusy')
class AskLocalPortfolioQuestionBusyFailure
    extends AskLocalPortfolioQuestionFailure {
  const AskLocalPortfolioQuestionBusyFailure({super.cause});
}

class AskLocalPortfolioQuestionParams extends Equatable {
  const AskLocalPortfolioQuestionParams({
    required this.question,
    required this.portfolioContext,
    this.onPartialAnswer,
  });

  final String question;
  final String portfolioContext;

  /// Receives a generated answer as it grows; see
  /// [LocalAssistantRepository.answer]. Not part of equality.
  final void Function(String partialAnswer)? onPartialAnswer;

  @override
  List<Object?> get props => [question, portfolioContext];
}

@register
class AskLocalPortfolioQuestionUseCase
    extends
        BaseUseCase<
          AssistantResponseEntity,
          AskLocalPortfolioQuestionParams,
          AskLocalPortfolioQuestionFailure
        > {
  AskLocalPortfolioQuestionUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<AskLocalPortfolioQuestionFailure, AssistantResponseEntity>>
  execute(AskLocalPortfolioQuestionParams params) async {
    final support = await _isLocalAssistantSupportedUseCase();
    if (support.isLeft || !support.right) {
      return const Left(AskLocalPortfolioQuestionUnavailableFailure());
    }
    final answer = await _repository.answer(
      question: params.question,
      portfolioContext: params.portfolioContext,
      onPartialAnswer: params.onPartialAnswer,
    );
    return Right(AssistantTextResponseEntity(text: answer));
  }

  @protected
  @override
  AskLocalPortfolioQuestionFailure mapErrorToFailure(Object e, StackTrace st) =>
      switch (e) {
        LocalAssistantBusyException() => AskLocalPortfolioQuestionBusyFailure(
          cause: e,
        ),
        LocalAssistantUnavailableException() ||
        LocalAssistantCancelledException() =>
          AskLocalPortfolioQuestionUnavailableFailure(cause: e),
        _ => AskLocalPortfolioQuestionUnknownFailure(cause: e),
      };
}
