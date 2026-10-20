import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

extension MockSignInUseCaseStub on MockSignInUseCase {
  /// Stubs `call(param)` for any param to return [result].
  void stubCall(Either<SignInFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
