import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:use_case/use_case.dart';

class MockGetServicesUseCase extends Mock implements GetServicesUseCase {}

extension MockGetServicesUseCaseStub on MockGetServicesUseCase {
  void stubCall(Either<GetServicesFailure, List<ServiceEntity>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
