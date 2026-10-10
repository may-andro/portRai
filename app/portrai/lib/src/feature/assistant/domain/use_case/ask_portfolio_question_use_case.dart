import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:use_case/use_case.dart';

class AskPortfolioQuestionParams extends Equatable {
  const AskPortfolioQuestionParams({
    required this.question,
    required this.portfolioContext,
  });

  final String question;
  final String portfolioContext;

  @override
  List<Object?> get props => [question, portfolioContext];
}

@register
class AskPortfolioQuestionUseCase
    extends BaseUseCase<String, AskPortfolioQuestionParams, AssistantFailure> {
  AskPortfolioQuestionUseCase(this._repository);

  final AssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<AssistantFailure, String>> execute(
    AskPortfolioQuestionParams params,
  ) async {
    final answer = await _repository.answer(
      question: params.question,
      portfolioContext: params.portfolioContext,
    );
    return Right(answer);
  }

  @protected
  @override
  AssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssistantFailure(cause: e);
}
