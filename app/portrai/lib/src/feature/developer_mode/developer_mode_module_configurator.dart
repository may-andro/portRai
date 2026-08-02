import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/developer_mode/developer_mode_module_configurator.di.g.dart';
import 'package:portrai/src/feature/developer_mode/presentation/_presentation.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class DeveloperModeModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerDeveloperModeDependencies(sl);

  @override
  void postDependenciesSetup(ServiceLocator sl) {
    sl.get<ModuleRouteController>()
      ..register(DeveloperMenuModuleRoute.developerMenu)
      ..register(DeveloperMenuModuleRoute.featureFlag);
  }
}
