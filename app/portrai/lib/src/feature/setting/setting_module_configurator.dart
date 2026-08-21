import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/setting/presentation/_presentation.dart';
import 'package:portrai/src/feature/setting/setting_module_configurator.di.g.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class SettingModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerSettingDependencies(sl);

  @override
  void postDependenciesSetup(ServiceLocator sl) {
    sl.get<ModuleRouteController>().register(SettingModuleRoute.setting);
  }
}
