import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockResetFeatureFlagsUseCase extends Mock
    implements ResetFeatureFlagsUseCase {}

extension MockResetFeatureFlagsUseCaseStub on MockResetFeatureFlagsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<ResetFeatureFlagsFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
