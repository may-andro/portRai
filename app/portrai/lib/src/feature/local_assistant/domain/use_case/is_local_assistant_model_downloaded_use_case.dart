import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class IsLocalAssistantModelDownloadedFailure extends BasicFailure {
  const IsLocalAssistantModelDownloadedFailure({super.cause});
}

@Localizable('assistantError')
class IsLocalAssistantModelDownloadedUnknownFailure
    extends IsLocalAssistantModelDownloadedFailure {
  const IsLocalAssistantModelDownloadedUnknownFailure({super.cause});
}

@Localizable('errorLocalAssistantUnavailable')
class IsLocalAssistantModelDownloadedUnavailableFailure
    extends IsLocalAssistantModelDownloadedFailure {
  const IsLocalAssistantModelDownloadedUnavailableFailure({super.cause});
}

@register
class IsLocalAssistantModelDownloadedUseCase
    extends BaseNoParamUseCase<bool, IsLocalAssistantModelDownloadedFailure> {
  IsLocalAssistantModelDownloadedUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<IsLocalAssistantModelDownloadedFailure, bool>>
  execute() async {
    final support = await _isLocalAssistantSupportedUseCase();
    if (support.isLeft || !support.right) {
      return const Left(IsLocalAssistantModelDownloadedUnavailableFailure());
    }
    return Right(await _repository.isModelDownloaded());
  }

  @protected
  @override
  IsLocalAssistantModelDownloadedFailure mapErrorToFailure(
    Object e,
    StackTrace st,
  ) => switch (e) {
    LocalAssistantUnavailableException() ||
    LocalAssistantCancelledException() =>
      IsLocalAssistantModelDownloadedUnavailableFailure(cause: e),
    _ => IsLocalAssistantModelDownloadedUnknownFailure(cause: e),
  };
}
