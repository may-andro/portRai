import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class DeleteAssistantModelUseCase
    extends BaseNoParamUseCase<void, AssistantFailure> {
  DeleteAssistantModelUseCase(this._repository);

  final AssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<AssistantFailure, void>> execute() async {
    await _repository.deleteModel();
    return const Right(null);
  }

  @protected
  @override
  AssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssistantFailure(cause: e);
}
