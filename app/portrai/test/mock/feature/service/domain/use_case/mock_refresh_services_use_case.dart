import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:use_case/use_case.dart';

class MockRefreshServicesUseCase extends Mock
    implements RefreshServicesUseCase {}

extension MockRefreshServicesUseCaseStub on MockRefreshServicesUseCase {
  void stubCall(Either<RefreshServicesFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
