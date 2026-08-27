import 'dart:async';

import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/force_update/domain/repository/app_version_repository.dart';
import 'package:use_case/use_case.dart';

sealed class IsAppUpdateRequiredFailure extends BasicFailure {
  const IsAppUpdateRequiredFailure({super.cause});
}

class IsAppUpdateRequiredUnknownFailure extends IsAppUpdateRequiredFailure {
  const IsAppUpdateRequiredUnknownFailure({super.cause});
}

/// Checks whether the currently running app version is below the
/// `minimumRequiredAppVersion` configured in [AppConfig].
@register
class IsAppUpdateRequiredUseCase
    extends BaseNoParamUseCase<bool, IsAppUpdateRequiredFailure> {
  IsAppUpdateRequiredUseCase(
    this._getMinimumRequiredAppVersionUseCase,
    this._appVersionRepository,
  );

  final GetMinimumRequiredAppVersionUseCase
  _getMinimumRequiredAppVersionUseCase;
  final AppVersionRepository _appVersionRepository;

  @protected
  @override
  FutureOr<Either<IsAppUpdateRequiredFailure, bool>> execute() async {
    final minimumRequiredAppVersionResult =
        await _getMinimumRequiredAppVersionUseCase();

    if (minimumRequiredAppVersionResult.isLeft) {
      return Left(
        IsAppUpdateRequiredUnknownFailure(
          cause: minimumRequiredAppVersionResult.left,
        ),
      );
    }

    final currentAppVersion = await _appVersionRepository
        .getCurrentAppVersion();

    return Right(
      currentAppVersion.isLowerVersionThan(
        minimumRequiredAppVersionResult.right,
      ),
    );
  }

  @protected
  @override
  IsAppUpdateRequiredFailure mapErrorToFailure(Object e, StackTrace st) {
    return IsAppUpdateRequiredUnknownFailure(cause: e);
  }
}
