import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/data/cache/service_cache.dart';
import 'package:portrai/src/feature/service/data/model/service_model.dart';

void main() {
  group('ServiceCache', () {
    final cache = ServiceCache();
    final model = ServiceModel(
      title: 'App Development',
      description: 'Beautiful apps',
      image: 'service.png',
      detail: 'Detailed service description',
      locale: 'en',
    );

    test('should serialize all fields for storage when writing a model', () {
      final result = cache.serialize(model);

      expect(result['title'], model.title);
      expect(result['description'], model.description);
      expect(result['image'], model.image);
      expect(result['detail'], model.detail);
      expect(result['locale'], model.locale);
    });

    test('should restore all fields when reading a stored model', () {
      final stored = cache.serialize(model);

      final result = cache.deserialize(stored);

      expect(result.toJson(), model.toJson());
    });

    test('should use title and locale as the composite key when caching', () {
      expect(cache.primaryKeyColumns, ['title', 'locale']);
    });
  });
}
