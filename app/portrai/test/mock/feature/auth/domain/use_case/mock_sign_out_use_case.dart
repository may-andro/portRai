import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

extension MockSignOutUseCaseStub on MockSignOutUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<SignOutFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
