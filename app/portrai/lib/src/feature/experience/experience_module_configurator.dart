import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/experience_module_configurator.di.g.dart';
import 'package:portrai/src/feature/experience/presentation/_presentation.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class ExperienceModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerExperienceDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(ExperienceModuleRoute.experiences);
  }
}
