import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetExperienceUseCase extends Mock implements GetExperienceUseCase {}

extension MockGetExperienceUseCaseStub on MockGetExperienceUseCase {
  void stubCall(
    String id,
    Either<GetExperienceFailure, ExperienceEntity> result,
  ) {
    when(() => this(id)).thenAnswer((_) => result);
  }
}
