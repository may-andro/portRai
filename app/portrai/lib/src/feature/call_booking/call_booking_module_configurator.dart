import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/call_booking_module_configurator.di.g.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:portrai/src/feature/call_booking/presentation/route/_route.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class CallBookingModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerCallBookingDependencies(sl);

  @override
  void postDependenciesSetup(ServiceLocator sl) {
    sl.get<ModuleRouteController>().register(CallBookingModuleRoute.bookCall);

    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in CallBookingFeatureFlags.all) {
      registry.register(definition);
    }
  }
}
