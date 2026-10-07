import 'dart:async';

import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/app_config_module_configurator.di.g.dart';
import 'package:portrai/src/feature/app_config/domain/_domain.dart';

@generateConfigurator
class AppConfigModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerAppConfigDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final initializeAppConfigUseCase = sl.get<InitializeAppConfigUseCase>();
    final appConfigEither = await initializeAppConfigUseCase();

    if (appConfigEither.isLeft) {
      throw PostInjectionException(
        'App config could not be loaded from remote or cache',
        appConfigEither.left,
      );
    }

    sl.registerSingleton<AppConfig>(() => appConfigEither.right);
  }
}
