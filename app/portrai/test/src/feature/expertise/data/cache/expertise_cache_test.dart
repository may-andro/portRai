import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/data/cache/expertise_cache.dart';
import 'package:portrai/src/feature/expertise/data/model/expertise_model.dart';

void main() {
  group('ExpertiseCache', () {
    final cache = ExpertiseCache();
    final model = ExpertiseModel(
      image: 'https://example.com/flutter.png',
      title: 'Flutter Development',
      skills: const ['Flutter SDK', 'State Management'],
      locale: 'en',
    );

    test('should serialize skill lists for storage when writing a model', () {
      final result = cache.serialize(model);

      expect(result['image'], model.image);
      expect(result['title'], model.title);
      expect(result['skills'], '["Flutter SDK","State Management"]');
      expect(result['locale'], model.locale);
    });

    test('should restore skill lists when reading a stored model', () {
      final stored = cache.serialize(model);

      final result = cache.deserialize(stored);

      expect(result.toJson(), model.toJson());
    });

    test('should use title and locale as the composite key when caching', () {
      expect(cache.primaryKeyColumns, ['title', 'locale']);
    });
  });
}
