import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockShouldShowOnboardingUseCase extends Mock
    implements ShouldShowOnboardingUseCase {}

extension MockShouldShowOnboardingUseCaseStub
    on MockShouldShowOnboardingUseCase {
  void stubCall(Either<ShouldShowOnboardingFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
