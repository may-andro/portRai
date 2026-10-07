import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetExperiencesUseCase extends Mock implements GetExperiencesUseCase {}

extension MockGetExperiencesUseCaseStub on MockGetExperiencesUseCase {
  void stubCall(Either<GetExperiencesFailure, List<ExperienceEntity>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
