import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockCheckInternetConnectionUseCase extends Mock
    implements CheckInternetConnectionUseCase {}

extension MockCheckInternetConnectionUseCaseStub
    on MockCheckInternetConnectionUseCase {
  void stubCall(Either<CheckInternetConnectionFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
