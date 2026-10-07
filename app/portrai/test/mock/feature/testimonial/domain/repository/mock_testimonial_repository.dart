import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

class MockTestimonialRepository extends Mock implements TestimonialRepository {}

extension MockTestimonialRepositoryStub on MockTestimonialRepository {
  void stubCacheTestimonial(TestimonialEntity testimonial) {
    when(() => cacheTestimonial(testimonial)).thenAnswer((_) async {});
  }

  void stubCacheTestimonialThrows({
    required TestimonialEntity testimonial,
    required Object error,
  }) {
    when(() => cacheTestimonial(testimonial)).thenThrow(error);
  }

  void stubGetTestimonial({
    required String id,
    required TestimonialEntity testimonial,
  }) {
    when(() => getTestimonial(id)).thenAnswer((_) async => testimonial);
  }

  void stubGetTestimonialThrows({required String id, required Object error}) {
    when(() => getTestimonial(id)).thenThrow(error);
  }

  void stubGetTestimonials(List<TestimonialEntity> testimonials) {
    when(() => getTestimonials()).thenAnswer((_) async => testimonials);
  }

  void stubGetTestimonialsThrows(Object error) {
    when(() => getTestimonials()).thenThrow(error);
  }
}
