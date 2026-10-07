import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/data/cache/testimonial_cache.dart';

import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  final cache = TestimonialCache();
  final model = createTestimonialModel();

  group('TestimonialCache', () {
    test('should preserve all model fields when serializing for storage', () {
      final result = cache.serialize(model);

      expect(result['id'], model.id);
      expect(result['name'], model.name);
      expect(result['locale'], model.locale);
    });

    test('should restore all model fields when reading a stored model', () {
      final stored = cache.serialize(model);

      final result = cache.deserialize(stored);

      expect(result.toJson(), model.toJson());
    });

    test('should use ID and locale as the composite key when caching', () {
      expect(cache.primaryKeyColumns, ['id', 'locale']);
    });
  });
}
