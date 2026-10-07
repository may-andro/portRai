import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:use_case/use_case.dart';

class MockOpenEmailUseCase extends Mock implements OpenEmailUseCase {}

extension MockOpenEmailUseCaseStub on MockOpenEmailUseCase {
  void stubCall(String email, Either<OpenEmailFailure, bool> result) {
    when(() => this(email)).thenAnswer((_) => result);
  }
}
