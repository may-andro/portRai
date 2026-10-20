import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

class MockAiImageRepository extends Mock implements AiImageRepository {}

extension MockAiImageRepositoryStub on MockAiImageRepository {
  /// Stubs `getCachedAiImage(...)` to return [cachedImage].
  void stubGetCachedAiImage(AiImageEntity? cachedImage) {
    when(
      () => getCachedAiImage(
        sourceImageUrl: any(named: 'sourceImageUrl'),
        prompt: any(named: 'prompt'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async => cachedImage);
  }

  void stubGenerateAiImage(AiImageEntity result) {
    when(
      () => generateAiImage(
        sourceImageUrl: any(named: 'sourceImageUrl'),
        prompt: any(named: 'prompt'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubGenerateAiImageError(Object error) {
    when(
      () => generateAiImage(
        sourceImageUrl: any(named: 'sourceImageUrl'),
        prompt: any(named: 'prompt'),
        model: any(named: 'model'),
      ),
    ).thenThrow(error);
  }
}
