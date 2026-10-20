import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSaveGuestUserUseCase extends Mock implements SaveGuestUserUseCase {}

extension MockSaveGuestUserUseCaseStub on MockSaveGuestUserUseCase {
  void stubCall(
    GuestUserEntity user,
    Either<SaveGuestUserFailure, void> result,
  ) {
    when(() => this(user)).thenAnswer((_) => result);
  }
}
