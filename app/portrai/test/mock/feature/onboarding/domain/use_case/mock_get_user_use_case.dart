import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetUserUseCase extends Mock implements GetUserUseCase {}

extension MockGetUserUseCaseStub on MockGetUserUseCase {
  void stubCall(UserEntity? user) {
    when(() => this()).thenAnswer((_) => Right<NoFailure, UserEntity?>(user));
  }
}
