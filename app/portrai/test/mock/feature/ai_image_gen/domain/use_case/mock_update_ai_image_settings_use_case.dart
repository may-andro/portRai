import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockUpdateAiImageSettingsUseCase extends Mock
    implements UpdateAiImageSettingsUseCase {}

extension MockUpdateAiImageSettingsUseCaseStub
    on MockUpdateAiImageSettingsUseCase {
  void registerFallbacks() => registerFallbackValue(const AiImageSettings());

  void stubCall(Either<UpdateAiImageSettingsFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
