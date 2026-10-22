import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';
import 'package:portrai/src/feature/permission/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

/// Whether this platform has a permission to ask for, so features can hide
/// what depends on it elsewhere.
@register
class IsPermissionSupportedUseCase
    extends BaseUseCase<bool, AppPermission, NoFailure> {
  IsPermissionSupportedUseCase(this._repository);

  final PermissionRepository _repository;

  @protected
  @override
  Either<NoFailure, bool> execute(AppPermission permission) =>
      Right(_repository.isSupported(permission));

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
