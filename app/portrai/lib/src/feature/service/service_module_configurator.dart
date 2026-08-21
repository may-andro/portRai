import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/presentation/_presentation.dart';
import 'package:portrai/src/feature/service/service_module_configurator.di.g.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class ServiceModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerServiceDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(ServiceModuleRoute.service);
    sl.get<ModuleRouteController>().register(ServiceModuleRoute.services);
  }
}
