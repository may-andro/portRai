import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/data/cache/testimonial_cache.dart';
import 'package:portrai/src/feature/testimonial/data/model/testimonial_model.dart';

class MockTestimonialCache extends Mock implements TestimonialCache {}

extension MockTestimonialCacheStub on MockTestimonialCache {
  void stubGet({
    required Map<String, Object?> conditions,
    required TestimonialModel? result,
  }) {
    when(() => get(conditions: conditions)).thenAnswer((_) async => result);
  }

  void stubGetThrows({
    required Map<String, Object?> conditions,
    required Object error,
  }) {
    when(() => get(conditions: conditions)).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }

  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }

  void stubQuery({
    required Map<String, Object?> conditions,
    required List<TestimonialModel> result,
  }) {
    when(() => query(conditions: conditions)).thenAnswer((_) async => result);
  }

  void stubQueryThrows({
    required Map<String, Object?> conditions,
    required Object error,
  }) {
    when(() => query(conditions: conditions)).thenThrow(error);
  }
}
