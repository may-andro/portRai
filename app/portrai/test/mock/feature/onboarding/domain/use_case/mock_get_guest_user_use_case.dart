import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetGuestUserUseCase extends Mock implements GetGuestUserUseCase {}

extension MockGetGuestUserUseCaseStub on MockGetGuestUserUseCase {
  void stubCall(GuestUserEntity? user) {
    when(
      () => this(),
    ).thenAnswer((_) => Right<NoFailure, GuestUserEntity?>(user));
  }
}
