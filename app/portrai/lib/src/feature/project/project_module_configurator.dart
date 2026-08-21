import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/presentation/_presentation.dart';
import 'package:portrai/src/feature/project/project_module_configurator.di.g.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class ProjectModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerProjectDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(ProjectModuleRoute.projectDetail);
  }
}
