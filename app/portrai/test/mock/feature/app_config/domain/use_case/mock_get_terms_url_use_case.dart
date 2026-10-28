import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:use_case/use_case.dart';

class MockGetTermsUrlUseCase extends Mock implements GetTermsUrlUseCase {}

extension MockGetTermsUrlUseCaseStub on MockGetTermsUrlUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetTermsUrlFailure, Uri> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
