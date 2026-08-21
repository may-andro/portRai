import 'package:module_injector/module_injector.dart';

import 'package:portrai/src/feature/external_app_handler/external_app_handler_module_configurator.di.g.dart';

@generateConfigurator
class ExternalAppHandlerModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerExternalAppHandlerDependencies(sl);
}
