import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class PrepareAssistantModelUseCase
    extends BaseUseCase<void, void Function(int), AssistantFailure> {
  PrepareAssistantModelUseCase(this._repository);

  final AssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<AssistantFailure, void>> execute(
    void Function(int) onProgress,
  ) async {
    await _repository.prepareModel(onProgress: onProgress);
    return const Right(null);
  }

  @protected
  @override
  AssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssistantFailure(cause: e);
}
