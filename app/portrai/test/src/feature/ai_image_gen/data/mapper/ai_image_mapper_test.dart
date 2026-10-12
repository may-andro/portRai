import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/ai_image_gen/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

void main() {
  group('AiImageMapper', () {
    const mapper = AiImageMapper();
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('should map entity to model when a key is supplied', () {
      final model = mapper.toModel(
        AiImageEntity(bytes: bytes, mimeType: 'image/png'),
        key: 'key',
      );

      expect(model.key, 'key');
      expect(model.mimeType, 'image/png');
      expect(model.bytes, bytes);
    });

    test('should map model to entity when mapping a cached image', () {
      final entity = mapper.toEntity(
        mapper.toModel(
          AiImageEntity(bytes: bytes, mimeType: 'image/webp'),
          key: 'key',
        ),
      );

      expect(entity, AiImageEntity(bytes: bytes, mimeType: 'image/webp'));
    });
  });
}
