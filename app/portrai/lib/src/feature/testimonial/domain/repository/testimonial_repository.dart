import 'package:portrai/src/feature/testimonial/domain/entity/_entity.dart';

abstract class TestimonialRepository {
  Future<TestimonialEntity> getTestimonial(String id);

  Future<List<TestimonialEntity>> getTestimonials();

  Future<void> cacheTestimonials(List<TestimonialEntity> testimonials);

  /// Replaces the cached testimonials of the current locale with the latest
  /// ones.
  Future<void> refreshTestimonials();
}
