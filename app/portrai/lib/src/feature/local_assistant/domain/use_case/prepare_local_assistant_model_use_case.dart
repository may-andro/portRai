import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_supported_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

@register
class PrepareLocalAssistantModelUseCase
    extends BaseUseCase<void, void Function(int), LocalAssistantFailure> {
  PrepareLocalAssistantModelUseCase(
    this._repository,
    this._isLocalAssistantSupportedUseCase,
    this._getPermissionStatusUseCase,
  );

  final LocalAssistantRepository _repository;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;
  final GetPermissionStatusUseCase _getPermissionStatusUseCase;

  @protected
  @override
  FutureOr<Either<LocalAssistantFailure, void>> execute(
    void Function(int) onProgress,
  ) async {
    final support = await _isLocalAssistantSupportedUseCase();
    if (support.isLeft || !support.right) {
      return const Left(UnavailableLocalAssistantFailure());
    }
    // The download shows a notification whenever the app may show one.
    final notificationStatusEither = await _getPermissionStatusUseCase(
      AppPermission.notifications,
    );
    await _repository.prepareModel(
      onProgress: onProgress,
      showsNotification:
          notificationStatusEither.isRight &&
          notificationStatusEither.right.isGranted,
    );
    return const Right(null);
  }

  @protected
  @override
  LocalAssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      e.toLocalAssistantFailure;
}
