import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class PrepareLocalAssistantModelUseCase
    extends BaseUseCase<void, void Function(int), LocalAssistantFailure> {
  PrepareLocalAssistantModelUseCase(this._repository);

  final LocalAssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<LocalAssistantFailure, void>> execute(
    void Function(int) onProgress,
  ) async {
    await _repository.prepareModel(onProgress: onProgress);
    return const Right(null);
  }

  @protected
  @override
  LocalAssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownLocalAssistantFailure(cause: e);
}
