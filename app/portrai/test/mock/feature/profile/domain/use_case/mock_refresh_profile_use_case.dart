import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

class MockRefreshProfileUseCase extends Mock implements RefreshProfileUseCase {}

extension MockRefreshProfileUseCaseStub on MockRefreshProfileUseCase {
  void stubCall(Either<RefreshProfileFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
