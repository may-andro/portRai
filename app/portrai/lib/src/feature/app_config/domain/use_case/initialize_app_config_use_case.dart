import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';
import 'package:portrai/src/feature/app_config/domain/repository/app_config_repository.dart';
import 'package:use_case/use_case.dart';

sealed class InitializeAppConfigFailure extends BasicFailure {
  const InitializeAppConfigFailure({super.cause});
}

class InitializeAppConfigNetworkFailure extends InitializeAppConfigFailure {
  const InitializeAppConfigNetworkFailure({super.cause});
}

class InitializeAppConfigCacheFailure extends InitializeAppConfigFailure {
  const InitializeAppConfigCacheFailure({super.cause});
}

class InitializeAppConfigUnknownFailure extends InitializeAppConfigFailure {
  const InitializeAppConfigUnknownFailure({super.cause});
}

/// Fetches [PortraiAppConfigEntity] from remote (falling back to cache) so it can
/// be registered as the app-wide `AppConfig` singleton.
///
/// This is a **startup-only** use case: it is meant to be called exactly
/// once, by `AppConfigModuleConfigurator` during DI setup. Do not call it
/// from other use cases, blocs, or widgets to "get" the current app config -
/// once startup has registered it, retrieve it via `sl.get<AppConfig>()`
/// (or inject `AppConfig` directly) instead.
@register
class InitializeAppConfigUseCase
    extends
        BaseNoParamUseCase<PortraiAppConfigEntity, InitializeAppConfigFailure> {
  InitializeAppConfigUseCase(this._appConfigRepository);

  final AppConfigRepository _appConfigRepository;

  @protected
  @override
  FutureOr<Either<InitializeAppConfigFailure, PortraiAppConfigEntity>>
  execute() async {
    final appConfig = await _appConfigRepository.getAppConfig();
    return Right(appConfig);
  }

  @protected
  @override
  InitializeAppConfigFailure mapErrorToFailure(Object e, StackTrace st) {
    final errorMessage = e.toString().toLowerCase();

    if (errorMessage.contains('network') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('unauthorized')) {
      return InitializeAppConfigNetworkFailure(cause: e);
    }

    if (errorMessage.contains('cache')) {
      return InitializeAppConfigCacheFailure(cause: e);
    }

    return InitializeAppConfigUnknownFailure(cause: e);
  }
}
