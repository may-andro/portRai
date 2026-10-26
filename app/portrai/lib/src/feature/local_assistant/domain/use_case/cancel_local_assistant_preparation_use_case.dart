import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class CancelLocalAssistantPreparationFailure extends BasicFailure {
  const CancelLocalAssistantPreparationFailure({super.cause});
}

@Localizable('assistantError')
class CancelLocalAssistantPreparationUnknownFailure
    extends CancelLocalAssistantPreparationFailure {
  const CancelLocalAssistantPreparationUnknownFailure({super.cause});
}

@Localizable('errorLocalAssistantUnavailable')
class CancelLocalAssistantPreparationUnavailableFailure
    extends CancelLocalAssistantPreparationFailure {
  const CancelLocalAssistantPreparationUnavailableFailure({super.cause});
}

@register
class CancelLocalAssistantPreparationUseCase
    extends BaseNoParamUseCase<void, CancelLocalAssistantPreparationFailure> {
  CancelLocalAssistantPreparationUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<CancelLocalAssistantPreparationFailure, void>>
  execute() async {
    final support = await _isLocalAssistantSupportedUseCase();
    if (support.isLeft || !support.right) {
      return const Left(CancelLocalAssistantPreparationUnavailableFailure());
    }
    await _repository.cancelPreparation();
    return const Right(null);
  }

  @protected
  @override
  CancelLocalAssistantPreparationFailure mapErrorToFailure(
    Object e,
    StackTrace st,
  ) => switch (e) {
    LocalAssistantUnavailableException() ||
    LocalAssistantCancelledException() =>
      CancelLocalAssistantPreparationUnavailableFailure(cause: e),
    _ => CancelLocalAssistantPreparationUnknownFailure(cause: e),
  };
}
