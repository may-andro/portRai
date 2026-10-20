import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit_module_configurator.di.g.dart';

@generateConfigurator
class AiRateLimitModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerAiRateLimitDependencies(sl);
}
