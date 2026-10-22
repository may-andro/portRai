import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';
import 'package:portrai/src/feature/permission/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RequestPermissionFailure extends BasicFailure {
  const RequestPermissionFailure({super.cause});
}

@Localizable('errorPermissionRequest')
final class RequestPermissionUnknownFailure extends RequestPermissionFailure {
  const RequestPermissionUnknownFailure({super.cause});
}

/// Asks the user for a permission unless it is already decided, and returns
/// the resulting status. A permission that is granted, or that only the
/// device settings can change, is returned without a prompt.
@register
class RequestPermissionUseCase
    extends
        BaseUseCase<
          AppPermissionStatus,
          AppPermission,
          RequestPermissionFailure
        > {
  RequestPermissionUseCase(this._repository);

  final PermissionRepository _repository;

  @protected
  @override
  FutureOr<Either<RequestPermissionFailure, AppPermissionStatus>> execute(
    AppPermission permission,
  ) async {
    final status = await _repository.status(permission);
    if (status != AppPermissionStatus.denied) return Right(status);
    return Right(await _repository.request(permission));
  }

  @protected
  @override
  RequestPermissionFailure mapErrorToFailure(Object e, StackTrace st) =>
      RequestPermissionUnknownFailure(cause: e);
}
