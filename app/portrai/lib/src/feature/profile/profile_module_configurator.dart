import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/presentation/_presentation.dart';
import 'package:portrai/src/feature/profile/profile_module_configurator.di.g.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class ProfileModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerProfileDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(ProfileModuleRoute.profile);
  }
}
