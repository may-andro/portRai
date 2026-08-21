import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag_module_configurator.di.g.dart';
import 'package:portrai/src/feature/feature_flag/presentation/route/_route.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class AppFeatureFlagModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerAppFeatureFlagDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(
      FeatureFlagModuleRoute.featureFlag,
    );
  }
}
