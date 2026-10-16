import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockResolveAiImageRequestSettingsUseCase extends Mock
    implements ResolveAiImageRequestSettingsUseCase {}

extension MockResolveAiImageRequestSettingsUseCaseStub
    on MockResolveAiImageRequestSettingsUseCase {
  void stubCall(AiImageRequestSettings settings) {
    when(
      () => this(),
    ).thenAnswer((_) => Right<NoFailure, AiImageRequestSettings>(settings));
  }
}
