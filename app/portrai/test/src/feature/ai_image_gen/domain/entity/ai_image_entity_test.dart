import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

void main() {
  test('should not print the image bytes when converted to a string', () {
    final entity = AiImageEntity(
      bytes: Uint8List(100000),
      mimeType: 'image/png',
    );

    expect(
      entity.toString(),
      'AiImageEntity(mimeType: image/png, bytes: 100000)',
    );
  });
}
