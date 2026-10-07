import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/data/cache/project_cache.dart';

import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  group('ProjectCache', () {
    final cache = ProjectCache();
    final model = createProjectModel();

    test('should serialize list fields for storage when writing a model', () {
      final result = cache.serialize(model);

      expect(result['technologies'], '["Flutter","Dart"]');
      expect(result['features'], '["Localization","Tracking"]');
      expect(result['achievements'], '["Launched to production"]');
      expect(result['id'], model.id);
      expect(result['locale'], model.locale);
    });

    test('should restore list fields when reading a stored model', () {
      final stored = cache.serialize(model);

      final result = cache.deserialize(stored);

      expect(result.toJson(), model.toJson());
    });

    test('should use ID and locale as the composite key when caching', () {
      expect(cache.primaryKeyColumns, ['id', 'locale']);
    });
  });
}
