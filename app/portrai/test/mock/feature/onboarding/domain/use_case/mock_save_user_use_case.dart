import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSaveUserUseCase extends Mock implements SaveUserUseCase {}

extension MockSaveUserUseCaseStub on MockSaveUserUseCase {
  void stubCall(UserEntity user, Either<SaveUserFailure, void> result) {
    when(() => this(user)).thenAnswer((_) => result);
  }
}
