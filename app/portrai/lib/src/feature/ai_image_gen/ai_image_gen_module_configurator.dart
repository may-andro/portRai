import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen_module_configurator.di.g.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

@generateConfigurator
class AiImageGenModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerAiImageGenDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in AiImageGenFeatureFlags.all) {
      registry.register(definition);
    }
  }
}
