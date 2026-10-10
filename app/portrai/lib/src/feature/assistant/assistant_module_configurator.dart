import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant_availability.dart';
import 'package:portrai/src/feature/assistant/assistant_module_configurator.di.g.dart';
import 'package:portrai/src/feature/assistant/presentation/route/assistant_module_route.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class AssistantModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerAssistantDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    if (isAssistantSupported) {
      sl.get<ModuleRouteController>().register(AssistantModuleRoute.assistant);
    }
  }
}
