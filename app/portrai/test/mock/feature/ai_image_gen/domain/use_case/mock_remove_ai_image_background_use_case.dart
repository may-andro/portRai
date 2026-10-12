import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockRemoveAiImageBackgroundUseCase extends Mock
    implements RemoveAiImageBackgroundUseCase {}

extension MockRemoveAiImageBackgroundUseCaseStub
    on MockRemoveAiImageBackgroundUseCase {
  void stubCall(Either<RemoveAiImageBackgroundFailure, AiImageEntity> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
