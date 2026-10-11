import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant_module_configurator.di.g.dart';

@generateConfigurator
class AssistantModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerAssistantDependencies(sl);
}
