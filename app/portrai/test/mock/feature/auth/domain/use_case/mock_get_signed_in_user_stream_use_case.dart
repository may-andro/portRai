import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

class MockGetSignedInUserStreamUseCase extends Mock
    implements GetSignedInUserStreamUseCase {}

extension MockGetSignedInUserStreamUseCaseStub
    on MockGetSignedInUserStreamUseCase {
  void stubCall(Stream<AuthUserEntity?> users) {
    when(() => this()).thenAnswer((_) => users);
  }
}
