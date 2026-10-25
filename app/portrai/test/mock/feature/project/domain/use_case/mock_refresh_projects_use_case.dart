import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

class MockRefreshProjectsUseCase extends Mock
    implements RefreshProjectsUseCase {}

extension MockRefreshProjectsUseCaseStub on MockRefreshProjectsUseCase {
  void stubCall(Either<RefreshProjectsFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
