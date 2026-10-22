import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/permission/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class OpenPermissionSettingsFailure extends BasicFailure {
  const OpenPermissionSettingsFailure({super.cause});
}

@Localizable('errorPermissionSettings')
final class OpenPermissionSettingsUnknownFailure
    extends OpenPermissionSettingsFailure {
  const OpenPermissionSettingsUnknownFailure({super.cause});
}

/// Opens the app's page in the device settings, where the user can allow a
/// permission the system no longer prompts for.
@register
class OpenPermissionSettingsUseCase
    extends BaseNoParamUseCase<void, OpenPermissionSettingsFailure> {
  OpenPermissionSettingsUseCase(this._repository);

  final PermissionRepository _repository;

  @protected
  @override
  FutureOr<Either<OpenPermissionSettingsFailure, void>> execute() async {
    final opened = await _repository.openSettings();
    return opened
        ? const Right(null)
        : const Left(OpenPermissionSettingsUnknownFailure());
  }

  @protected
  @override
  OpenPermissionSettingsFailure mapErrorToFailure(Object e, StackTrace st) =>
      OpenPermissionSettingsUnknownFailure(cause: e);
}
