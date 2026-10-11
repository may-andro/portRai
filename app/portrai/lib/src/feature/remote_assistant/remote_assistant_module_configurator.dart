import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/route/_route.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant_module_configurator.di.g.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class RemoteAssistantModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerRemoteAssistantDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in RemoteAssistantFeatureFlags.all) {
      registry.register(definition);
    }
    sl.get<ModuleRouteController>().register(
      RemoteAssistantModuleRoute.assistant,
    );
  }
}
