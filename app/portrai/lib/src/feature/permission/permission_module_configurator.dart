import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/permission/permission_module_configurator.di.g.dart';

@generateConfigurator
class PermissionModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerPermissionDependencies(sl);
}
