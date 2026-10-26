import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class ResetRemoteAssistantSessionFailure extends BasicFailure {
  const ResetRemoteAssistantSessionFailure({super.cause});
}

@Localizable('errorRemoteAssistantUnknown')
class ResetRemoteAssistantSessionUnknownFailure
    extends ResetRemoteAssistantSessionFailure {
  const ResetRemoteAssistantSessionUnknownFailure({super.cause});
}

@register
class ResetRemoteAssistantSessionUseCase
    extends BaseNoParamUseCase<void, ResetRemoteAssistantSessionFailure> {
  ResetRemoteAssistantSessionUseCase(this._repository);

  final RemoteAssistantRepository _repository;

  @protected
  @override
  Future<Either<ResetRemoteAssistantSessionFailure, void>> execute() async {
    await _repository.resetSession();
    return const Right(null);
  }

  /// Only the sanitized [AiException] is kept as a cause; other errors may
  /// carry raw details, so they are dropped.
  @protected
  @override
  ResetRemoteAssistantSessionFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    AiException() => ResetRemoteAssistantSessionUnknownFailure(cause: error),
    _ => const ResetRemoteAssistantSessionUnknownFailure(),
  };
}
