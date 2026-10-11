import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/domain/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class ResetRemoteAssistantSessionUseCase
    extends BaseNoParamUseCase<void, RemoteAssistantFailure> {
  ResetRemoteAssistantSessionUseCase(this._repository);

  final RemoteAssistantRepository _repository;

  @protected
  @override
  Future<Either<RemoteAssistantFailure, void>> execute() async {
    await _repository.resetSession();
    return const Right(null);
  }

  @protected
  @override
  RemoteAssistantFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => error.toRemoteAssistantFailure();
}
