import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetAiImageSettingsUseCase extends Mock
    implements GetAiImageSettingsUseCase {}

extension MockGetAiImageSettingsUseCaseStub on MockGetAiImageSettingsUseCase {
  void stubCall(AiImageSettings? settings) {
    when(
      () => this(),
    ).thenAnswer((_) => Right<NoFailure, AiImageSettings?>(settings));
  }
}
