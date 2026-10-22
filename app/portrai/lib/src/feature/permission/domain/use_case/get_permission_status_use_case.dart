import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';
import 'package:portrai/src/feature/permission/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetPermissionStatusFailure extends BasicFailure {
  const GetPermissionStatusFailure({super.cause});
}

@Localizable('errorPermissionStatus')
final class GetPermissionStatusUnknownFailure
    extends GetPermissionStatusFailure {
  const GetPermissionStatusUnknownFailure({super.cause});
}

/// Returns whether the user allows a permission, without asking.
@register
class GetPermissionStatusUseCase
    extends
        BaseUseCase<
          AppPermissionStatus,
          AppPermission,
          GetPermissionStatusFailure
        > {
  GetPermissionStatusUseCase(this._repository);

  final PermissionRepository _repository;

  @protected
  @override
  FutureOr<Either<GetPermissionStatusFailure, AppPermissionStatus>> execute(
    AppPermission permission,
  ) async {
    return Right(await _repository.status(permission));
  }

  @protected
  @override
  GetPermissionStatusFailure mapErrorToFailure(Object e, StackTrace st) =>
      GetPermissionStatusUnknownFailure(cause: e);
}
