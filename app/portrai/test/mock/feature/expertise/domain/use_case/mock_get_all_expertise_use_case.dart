import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:use_case/use_case.dart';

class MockGetAllExpertiseUseCase extends Mock
    implements GetAllExpertiseUseCase {}

extension MockGetAllExpertiseUseCaseStub on MockGetAllExpertiseUseCase {
  void stubCall(Either<GetAllExpertiseFailure, List<ExpertiseEntity>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
