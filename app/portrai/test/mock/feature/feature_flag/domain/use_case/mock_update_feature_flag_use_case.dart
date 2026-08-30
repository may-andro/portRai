import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockUpdateFeatureFlagUseCase extends Mock
    implements UpdateFeatureFlagUseCase {}

extension MockUpdateFeatureFlagUseCaseStub on MockUpdateFeatureFlagUseCase {
  /// Stubs `call(flag)` to return [result].
  void stubCall(Either<UpdateFeatureFlagFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
