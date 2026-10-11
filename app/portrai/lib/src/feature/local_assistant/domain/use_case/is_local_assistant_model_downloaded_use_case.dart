import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class IsLocalAssistantModelDownloadedUseCase
    extends BaseNoParamUseCase<bool, LocalAssistantFailure> {
  IsLocalAssistantModelDownloadedUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<LocalAssistantFailure, bool>> execute() async {
    final support = await _isLocalAssistantSupportedUseCase();
    if (support.isLeft || !support.right) {
      return const Left(UnavailableLocalAssistantFailure());
    }
    return Right(await _repository.isModelDownloaded());
  }

  @protected
  @override
  LocalAssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      e.toLocalAssistantFailure;
}
