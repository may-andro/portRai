import 'package:portrai/src/feature/testimonial/domain/entity/_entity.dart';

abstract class TestimonialRepository {
  Future<TestimonialEntity> getTestimonial(String id);

  Future<List<TestimonialEntity>> getTestimonials();

  Future<void> cacheTestimonial(TestimonialEntity testimonial);
}
