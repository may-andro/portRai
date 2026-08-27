import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/force_update/force_update_module_configurator.di.g.dart';

@generateConfigurator
class ForceUpdateModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerForceUpdateDependencies(sl);
  }
}
