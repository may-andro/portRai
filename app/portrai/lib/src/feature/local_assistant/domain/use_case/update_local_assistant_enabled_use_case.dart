import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class UpdateLocalAssistantEnabledFailure extends BasicFailure {
  const UpdateLocalAssistantEnabledFailure({super.cause});
}

@Localizable('assistantError')
class UpdateLocalAssistantEnabledUnknownFailure
    extends UpdateLocalAssistantEnabledFailure {
  const UpdateLocalAssistantEnabledUnknownFailure({super.cause});
}

@Localizable('errorLocalAssistantUnavailable')
class UpdateLocalAssistantEnabledUnavailableFailure
    extends UpdateLocalAssistantEnabledFailure {
  const UpdateLocalAssistantEnabledUnavailableFailure({super.cause});
}

@register
class UpdateLocalAssistantEnabledUseCase
    extends BaseUseCase<void, bool, UpdateLocalAssistantEnabledFailure> {
  UpdateLocalAssistantEnabledUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<UpdateLocalAssistantEnabledFailure, void>> execute(
    bool enabled,
  ) async {
    if (enabled) {
      final support = await _isLocalAssistantSupportedUseCase();
      if (support.isLeft || !support.right) {
        return const Left(UpdateLocalAssistantEnabledUnavailableFailure());
      }
    }
    await _repository.setEnabled(enabled: enabled);
    return const Right(null);
  }

  @protected
  @override
  UpdateLocalAssistantEnabledFailure mapErrorToFailure(
    Object e,
    StackTrace st,
  ) => switch (e) {
    LocalAssistantUnavailableException() ||
    LocalAssistantCancelledException() =>
      UpdateLocalAssistantEnabledUnavailableFailure(cause: e),
    _ => UpdateLocalAssistantEnabledUnknownFailure(cause: e),
  };
}
