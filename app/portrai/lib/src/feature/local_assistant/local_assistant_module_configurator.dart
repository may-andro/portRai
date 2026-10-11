import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant_module_configurator.di.g.dart';
import 'package:portrai/src/feature/local_assistant/presentation/route/local_assistant_module_route.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class LocalAssistantModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerLocalAssistantDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in LocalAssistantFeatureFlags.all) {
      registry.register(definition);
    }

    final support = await sl.get<IsLocalAssistantSupportedUseCase>()();
    if (support.isLeft) {
      throw StateError('Could not determine local assistant platform support.');
    }
    if (support.right) {
      sl.get<ModuleRouteController>().register(
        LocalAssistantModuleRoute.assistant,
      );
      sl.get<LocalAssistantBloc>().add(const LocalAssistantInitializedEvent());
    }
  }
}
