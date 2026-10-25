import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

class MockWatchSignedInUserUseCase extends Mock
    implements WatchSignedInUserUseCase {}

extension MockWatchSignedInUserUseCaseStub on MockWatchSignedInUserUseCase {
  void stubCall(
    Stream<Either<WatchSignedInUserFailure, AuthUserEntity?>> stream,
  ) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
