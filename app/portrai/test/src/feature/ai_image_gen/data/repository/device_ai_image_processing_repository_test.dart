import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/_model.dart';
import 'package:portrai/src/feature/ai_image_gen/data/repository/device_ai_image_processing_repository.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

import '../../../../../mock/feature/ai_image_gen/data/cache/mock_ai_image_cache.dart';

void main() {
  late MockAiImageCache cache;
  late DeviceAiImageProcessingRepository repository;

  AiImageEntity buildImage(int size) {
    final source = img.Image(width: size, height: size)
      ..clear(img.ColorRgb8(255, 255, 255));
    img.fillRect(
      source,
      x1: size ~/ 4,
      y1: size ~/ 4,
      x2: size * 3 ~/ 4,
      y2: size * 3 ~/ 4,
      color: img.ColorRgb8(20, 20, 20),
    );
    return AiImageEntity(
      bytes: Uint8List.fromList(img.encodePng(source)),
      mimeType: 'image/png',
    );
  }

  setUpAll(
    () => registerFallbackValue(
      AiImageModel(key: '', mimeType: '', bytes: Uint8List(0)),
    ),
  );

  setUp(() {
    cache = MockAiImageCache();
    repository = DeviceAiImageProcessingRepository(
      const AiImageBackgroundRemover(),
      cache,
      const AiImageMapper(),
    );
  });

  testWidgets(
    'should return a transparent png and cache it when the image has a white background',
    (tester) async {
      cache
        ..stubGet(null)
        ..stubPut();

      await tester.runAsync(() async {
        final result = await repository.removeBackground(buildImage(16));

        final decoded = img.decodePng(result.bytes)!;
        expect(result.mimeType, 'image/png');
        expect(decoded.getPixel(0, 0).a, 0);
        expect(decoded.getPixel(8, 8).a, 255);
        verify(() => cache.put(any())).called(1);
      });
    },
  );

  testWidgets(
    'should shrink the image when its longest edge exceeds the maximum',
    (tester) async {
      cache
        ..stubGet(null)
        ..stubPut();

      await tester.runAsync(() async {
        final result = await repository.removeBackground(buildImage(1024));

        final decoded = img.decodePng(result.bytes)!;
        expect(decoded.width, AiImageBackgroundRemover.maxDimension);
      });
    },
  );

  testWidgets(
    'should return the cached image without processing when the cache has a match',
    (tester) async {
      final cached = Uint8List.fromList([7, 7]);
      cache.stubGet(
        AiImageModel(key: 'key', mimeType: 'image/png', bytes: cached),
      );

      await tester.runAsync(() async {
        final result = await repository.removeBackground(buildImage(16));

        expect(result, AiImageEntity(bytes: cached, mimeType: 'image/png'));
        verifyNever(() => cache.put(any()));
      });
    },
  );

  testWidgets(
    'should throw processing exception when the bytes are not an image',
    (tester) async {
      cache.stubGet(null);

      await tester.runAsync(() async {
        await expectLater(
          repository.removeBackground(
            AiImageEntity(
              bytes: Uint8List.fromList([1, 2]),
              mimeType: 'image/png',
            ),
          ),
          throwsA(isA<AiImageProcessingException>()),
        );
      });
    },
  );
}
