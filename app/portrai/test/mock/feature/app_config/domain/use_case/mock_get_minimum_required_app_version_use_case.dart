import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:use_case/use_case.dart';

class MockGetMinimumRequiredAppVersionUseCase extends Mock
    implements GetMinimumRequiredAppVersionUseCase {}

extension MockGetMinimumRequiredAppVersionUseCaseStub
    on MockGetMinimumRequiredAppVersionUseCase {
  /// Stubs `call()` to return `Right(minimumRequiredAppVersion)`.
  void stubCall(String minimumRequiredAppVersion) {
    when(call).thenReturn(Right(minimumRequiredAppVersion));
  }
}
