import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/cv_export_module_configurator.di.g.dart';
import 'package:portrai/src/feature/cv_export/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/cv_export/presentation/route/cv_export_module_route.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class CvExportModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerCvExportDependencies(sl);

  @override
  void postDependenciesSetup(ServiceLocator sl) {
    sl.get<ModuleRouteController>().register(CvExportModuleRoute.cvExport);
    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in CvExportFeatureFlags.all) {
      registry.register(definition);
    }
  }
}
