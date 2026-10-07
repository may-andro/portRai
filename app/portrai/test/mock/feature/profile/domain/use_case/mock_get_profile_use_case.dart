import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

extension MockGetProfileUseCaseStub on MockGetProfileUseCase {
  void stubCall(Either<GetProfileFailure, ProfileEntity> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
