import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/job_opening_module_configurator.di.g.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class JobOpeningModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerJobOpeningDependencies(sl);

  @override
  void postDependenciesSetup(ServiceLocator sl) {
    sl.get<ModuleRouteController>()
      ..register(JobOpeningModuleRoute.jobOpenings)
      ..register(JobOpeningModuleRoute.jobOpening);

    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in JobOpeningFeatureFlags.all) {
      registry.register(definition);
    }
  }
}
