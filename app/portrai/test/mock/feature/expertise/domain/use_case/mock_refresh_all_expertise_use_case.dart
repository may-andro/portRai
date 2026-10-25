import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:use_case/use_case.dart';

class MockRefreshAllExpertiseUseCase extends Mock
    implements RefreshAllExpertiseUseCase {}

extension MockRefreshAllExpertiseUseCaseStub on MockRefreshAllExpertiseUseCase {
  void stubCall(Either<RefreshAllExpertiseFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
