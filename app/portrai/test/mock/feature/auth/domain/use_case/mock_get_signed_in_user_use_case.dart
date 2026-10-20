import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetSignedInUserUseCase extends Mock
    implements GetSignedInUserUseCase {}

extension MockGetSignedInUserUseCaseStub on MockGetSignedInUserUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetSignedInUserFailure, AuthUserEntity?> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
