import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:use_case/use_case.dart';

class MockGetPrivacyPolicyUrlUseCase extends Mock
    implements GetPrivacyPolicyUrlUseCase {}

extension MockGetPrivacyPolicyUrlUseCaseStub on MockGetPrivacyPolicyUrlUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetPrivacyPolicyUrlFailure, Uri> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
