import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class DeleteLocalAssistantModelUseCase
    extends BaseNoParamUseCase<void, LocalAssistantFailure> {
  DeleteLocalAssistantModelUseCase(this._repository);

  final LocalAssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<LocalAssistantFailure, void>> execute() async {
    await _repository.deleteModel();
    return const Right(null);
  }

  @protected
  @override
  LocalAssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      e.toLocalAssistantFailure;
}
