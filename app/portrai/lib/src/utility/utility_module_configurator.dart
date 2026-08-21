import 'package:module_injector/module_injector.dart';

import 'package:portrai/src/utility/utility_module_configurator.di.g.dart';

@generateConfigurator
class UtilityModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerUtilityDependencies(sl);
}
