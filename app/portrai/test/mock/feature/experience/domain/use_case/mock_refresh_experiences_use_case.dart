import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockRefreshExperiencesUseCase extends Mock
    implements RefreshExperiencesUseCase {}

extension MockRefreshExperiencesUseCaseStub on MockRefreshExperiencesUseCase {
  void stubCall(Either<RefreshExperiencesFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
