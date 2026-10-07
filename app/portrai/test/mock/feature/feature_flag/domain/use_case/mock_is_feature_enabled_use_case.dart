import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsFeatureEnabledUseCase extends Mock
    implements IsFeatureEnabledUseCase {}

extension MockIsFeatureEnabledUseCaseStub on MockIsFeatureEnabledUseCase {
  void stubCall({
    required AppFeatureFlagDefinition definition,
    required Either<IsFeatureEnabledFailure, bool> result,
  }) {
    when(() => this(definition)).thenAnswer((_) => result);
  }
}
