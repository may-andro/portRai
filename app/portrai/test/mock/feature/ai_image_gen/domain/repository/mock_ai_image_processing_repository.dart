import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

class MockAiImageProcessingRepository extends Mock
    implements AiImageProcessingRepository {}

extension MockAiImageProcessingRepositoryStub
    on MockAiImageProcessingRepository {
  void stubRemoveBackground(AiImageEntity result) {
    when(() => removeBackground(any())).thenAnswer((_) async => result);
  }

  void stubRemoveBackgroundError(Object error) {
    when(() => removeBackground(any())).thenThrow(error);
  }
}
