import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/assistant/assistant_availability.dart';
import 'package:portrai/src/feature/assistant/assistant_module_configurator.di.g.dart';
import 'package:portrai/src/feature/assistant/presentation/route/assistant_module_route.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class AssistantModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerAssistantDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in AssistantFeatureFlags.all) {
      registry.register(definition);
    }

    if (isAssistantSupported) {
      sl.get<ModuleRouteController>().register(AssistantModuleRoute.assistant);
      sl.get<AssistantBloc>().add(const AssistantInitializedEvent());
    }
  }
}
