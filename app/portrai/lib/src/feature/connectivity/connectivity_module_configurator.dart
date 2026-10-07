import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/connectivity_module_configurator.di.g.dart';

@generateConfigurator
class ConnectivityModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerConnectivityDependencies(sl);
  }
}
