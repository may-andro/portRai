import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/user/user_module_configurator.di.g.dart';

@generateConfigurator
class UserModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) => $registerUserDependencies(sl);
}
