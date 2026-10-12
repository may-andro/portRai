import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGenerateAiImageUseCase extends Mock
    implements GenerateAiImageUseCase {}

extension MockGenerateAiImageUseCaseStub on MockGenerateAiImageUseCase {
  void stubCall(Either<GenerateAiImageFailure, AiImageEntity> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
