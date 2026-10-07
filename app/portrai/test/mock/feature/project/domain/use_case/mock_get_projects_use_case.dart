import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

class MockGetProjectsUseCase extends Mock implements GetProjectsUseCase {}

extension MockGetProjectsUseCaseStub on MockGetProjectsUseCase {
  void stubCall(Either<GetProjectsFailure, List<ProjectEntity>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
