import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/_testimonial_detail.dart';
import 'package:portrai/src/route/route.dart';

class TestimonialModuleRoute extends ModuleRoute {
  TestimonialModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final TestimonialModuleRoute testimonialDetail =
      TestimonialModuleRoute._(
        name: 'testimonial_detail',
        path: '/testimonial_detail',
        builder: (_, _, _) => const TestimonialDetailScreen(),
      );
}
