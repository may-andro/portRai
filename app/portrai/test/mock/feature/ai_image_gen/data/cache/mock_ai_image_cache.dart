import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/data/cache/_cache.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/_model.dart';

class MockAiImageCache extends Mock implements AiImageCache {}

extension MockAiImageCacheStub on MockAiImageCache {
  void stubGet(AiImageModel? result) {
    when(
      () => get(conditions: any(named: 'conditions')),
    ).thenAnswer((_) async => result);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async {});
  }
}
