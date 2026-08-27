import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

class MockGetMinimumRequiredAppVersionUseCase extends Mock
    implements GetMinimumRequiredAppVersionUseCase {}

extension MockGetMinimumRequiredAppVersionUseCaseStub
    on MockGetMinimumRequiredAppVersionUseCase {
  /// Stubs `call()` to return [minimumRequiredAppVersion].
  void stubCall(String minimumRequiredAppVersion) {
    when(call).thenReturn(minimumRequiredAppVersion);
  }
}
