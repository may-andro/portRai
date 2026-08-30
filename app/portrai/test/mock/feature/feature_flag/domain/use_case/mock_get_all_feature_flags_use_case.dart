import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetAllFeatureFlagsUseCase extends Mock
    implements GetAllFeatureFlagsUseCase {}

extension MockGetAllFeatureFlagsUseCaseStub on MockGetAllFeatureFlagsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(
    Either<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>> result,
  ) {
    when(() => this()).thenAnswer((_) => result);
  }
}
