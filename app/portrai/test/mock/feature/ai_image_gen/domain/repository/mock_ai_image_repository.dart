import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

class MockAiImageRepository extends Mock implements AiImageRepository {}

extension MockAiImageRepositoryStub on MockAiImageRepository {
  void stubGenerateAiImage(AiImageEntity result) {
    when(
      () => generateAiImage(
        sourceImageUrl: any(named: 'sourceImageUrl'),
        prompt: any(named: 'prompt'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubGenerateAiImageError(Object error) {
    when(
      () => generateAiImage(
        sourceImageUrl: any(named: 'sourceImageUrl'),
        prompt: any(named: 'prompt'),
      ),
    ).thenThrow(error);
  }
}
