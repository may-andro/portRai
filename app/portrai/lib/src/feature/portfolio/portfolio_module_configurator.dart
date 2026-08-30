import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/portfolio_module_configurator.di.g.dart';
import 'package:portrai/src/feature/portfolio/presentation/_presentation.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class PortfolioModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerPortfolioDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(PortfolioModuleRoute.portfolio);

    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in PortfolioFeatureFlags.all) {
      registry.register(definition);
    }
  }
}
