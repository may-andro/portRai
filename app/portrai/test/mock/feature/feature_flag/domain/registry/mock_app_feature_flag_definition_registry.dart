import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

class MockAppFeatureFlagDefinitionRegistry extends Mock
    implements AppFeatureFlagDefinitionRegistry {}

extension MockAppFeatureFlagDefinitionRegistryStub
    on MockAppFeatureFlagDefinitionRegistry {
  /// Stubs `all` to return [definitions].
  void stubAll(List<AppFeatureFlagDefinition> definitions) {
    when(() => all).thenReturn(definitions);
  }

  /// Stubs `all` to throw [error].
  void stubAllThrows(Object error) {
    when(() => all).thenThrow(error);
  }
}
