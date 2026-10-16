import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/_model.dart';
import 'package:portrai/src/feature/ai_image_gen/data/repository/firebase_ai_image_repository.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

import '../../../../../mock/feature/ai_image_gen/data/cache/mock_ai_image_cache.dart';
import '../../../../../mock/feature/ai_image_gen/data/mock_fb_ai_controller.dart';

void main() {
  group('FirebaseAiImageRepository', () {
    late MockFbAiController aiController;
    late MockAiImageCache cache;
    late FirebaseAiImageRepository repository;

    final bytes = Uint8List.fromList([1, 2, 3]);

    setUp(() {
      aiController = MockFbAiController();
      cache = MockAiImageCache();
      repository = FirebaseAiImageRepository(
        aiController,
        cache,
        const AiImageMapper(),
      );
    });

    test(
      'should return the cached image without generating when the cache has a match',
      () async {
        cache.stubGet(
          AiImageModel(key: 'key', mimeType: 'image/png', bytes: bytes),
        );

        final image = await repository
            .generateAiImage(
              sourceImageUrl: 'https://example.com/a.png',
              prompt: 'Draw',
              model: 'model',
            )
            .timeout(const Duration(seconds: 2));

        expect(image, AiImageEntity(bytes: bytes, mimeType: 'image/png'));
        verifyNever(
          () => aiController.createImageModel(
            model: any(named: 'model'),
            systemInstruction: any(named: 'systemInstruction'),
            safetySettings: any(named: 'safetySettings'),
          ),
        );
      },
    );

    test(
      'should complete every call when the same image is requested twice in a row',
      () async {
        cache.stubGet(
          AiImageModel(key: 'key', mimeType: 'image/png', bytes: bytes),
        );
        Future<AiImageEntity> request() => repository
            .generateAiImage(
              sourceImageUrl: 'https://example.com/a.png',
              prompt: 'Draw',
              model: 'model',
            )
            .timeout(const Duration(seconds: 2));

        await request();
        final second = await request();

        expect(second.bytes, bytes);
        verify(() => cache.get(conditions: any(named: 'conditions'))).called(2);
      },
    );

    test(
      'should throw a cache exception when reading the cache fails',
      () async {
        when(
          () => cache.get(conditions: any(named: 'conditions')),
        ).thenThrow(StateError('db'));

        await expectLater(
          repository.generateAiImage(
            sourceImageUrl: 'https://example.com/a.png',
            prompt: 'Draw',
            model: 'model',
          ),
          throwsA(isA<AiImageCacheException>()),
        );
      },
    );
  });
}
