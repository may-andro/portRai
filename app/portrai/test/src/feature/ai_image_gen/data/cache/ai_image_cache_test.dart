import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/ai_image_gen/data/cache/ai_image_cache.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/ai_image_model.dart';

void main() {
  group('AiImageCache', () {
    final cache = AiImageCache();
    final model = AiImageModel(
      key: 'portrait-sunset',
      mimeType: 'image/png',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    test('should only write values that have a table column when writing a '
        'model', () {
      final columnNames = cache.columns.map((column) => column.name);

      expect(cache.serialize(model).keys, everyElement(isIn(columnNames)));
    });

    test('should restore every field when reading a stored model', () {
      final restoredModel = cache.deserialize(cache.serialize(model));

      expect(restoredModel.key, model.key);
      expect(restoredModel.mimeType, model.mimeType);
      expect(restoredModel.bytes, model.bytes);
    });

    test('should use the key as the primary key when caching', () {
      expect(cache.primaryKeyColumns, ['key']);
    });
  });
}
