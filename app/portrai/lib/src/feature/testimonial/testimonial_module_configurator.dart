import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/presentation/_presentation.dart';
import 'package:portrai/src/feature/testimonial/testimonial_module_configurator.di.g.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class TestimonialModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerTestimonialDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    sl.get<ModuleRouteController>().register(
      TestimonialModuleRoute.testimonialDetail,
    );
  }
}
