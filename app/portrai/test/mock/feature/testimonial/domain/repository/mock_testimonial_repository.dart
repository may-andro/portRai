import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

class MockTestimonialRepository extends Mock implements TestimonialRepository {}

extension MockTestimonialRepositoryStub on MockTestimonialRepository {
  void stubCacheTestimonials(List<TestimonialEntity> testimonials) {
    when(() => cacheTestimonials(testimonials)).thenAnswer((_) async {});
  }

  void stubCacheTestimonialsThrows({
    required List<TestimonialEntity> testimonials,
    required Object error,
  }) {
    when(() => cacheTestimonials(testimonials)).thenThrow(error);
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
