import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class AskLocalPortfolioQuestionParams extends Equatable {
  const AskLocalPortfolioQuestionParams({
    required this.question,
    required this.portfolioContext,
  });

  final String question;
  final String portfolioContext;

  @override
  List<Object?> get props => [question, portfolioContext];
}

@register
class AskLocalPortfolioQuestionUseCase
    extends
        BaseUseCase<
          AssistantResponseEntity,
          AskLocalPortfolioQuestionParams,
          LocalAssistantFailure
        > {
  AskLocalPortfolioQuestionUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<LocalAssistantFailure, AssistantResponseEntity>> execute(
    AskLocalPortfolioQuestionParams params,
  ) async {
    final support = await _isLocalAssistantSupportedUseCase();
    if (support.isLeft || !support.right) {
      return const Left(UnavailableLocalAssistantFailure());
    }
    final answer = await _repository.answer(
      question: params.question,
      portfolioContext: params.portfolioContext,
    );
    return Right(AssistantTextResponseEntity(text: answer));
  }

  @protected
  @override
  LocalAssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      e.toLocalAssistantFailure;
}
