import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/data/cache/profile_cache.dart';

import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  group('ProfileCache', () {
    final cache = ProfileCache();
    final model = createProfileModel();

    test(
      'should serialize nested objects and lists for storage when writing a model',
      () {
        final result = cache.serialize(model);

        expect(result['publishedAt'], isA<String>());
        expect(result['resume'], isA<String>());
        expect(result['socialLinks'], isA<String>());
        expect(result['availability'], isA<String>());
        expect(result['workingHours'], isA<String>());
        expect(result['location'], isA<String>());
        expect(result['languages'], isA<String>());
        expect(result['educations'], isA<String>());
        expect(result['locale'], 'en');
      },
    );

    test(
      'should restore nested objects and lists when reading a stored model',
      () {
        final stored = cache.serialize(model);

        expect(cache.deserialize(stored).toJson(), model.toJson());
      },
    );

    test('should use email and locale as the composite key when caching', () {
      expect(cache.primaryKeyColumns, ['email', 'locale']);
    });
  });
}
