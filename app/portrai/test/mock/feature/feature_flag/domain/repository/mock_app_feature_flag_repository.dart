import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

class MockAppFeatureFlagRepository extends Mock
    implements AppFeatureFlagRepository {}

extension MockAppFeatureFlagRepositoryStub on MockAppFeatureFlagRepository {
  /// Stubs `isFeatureEnabled(definition)` to return [isEnabled].
  void stubIsFeatureEnabled({
    required AppFeatureFlagDefinition definition,
    required bool isEnabled,
  }) {
    when(() => isFeatureEnabled(definition)).thenReturn(isEnabled);
  }

  /// Stubs `isFeatureEnabled(definition)` to throw [error].
  void stubIsFeatureEnabledThrows({
    required AppFeatureFlagDefinition definition,
    required Object error,
  }) {
    when(() => isFeatureEnabled(definition)).thenThrow(error);
  }

  /// Stubs `updateFeatureFlag(flag)` to complete successfully.
  void stubUpdateFeatureFlag(AppFeatureFlagEntity flag) {
    when(() => updateFeatureFlag(flag)).thenAnswer((_) async {});
  }

  /// Stubs `updateFeatureFlag(flag)` to throw [error].
  void stubUpdateFeatureFlagThrows({
    required AppFeatureFlagEntity flag,
    required Object error,
  }) {
    when(() => updateFeatureFlag(flag)).thenThrow(error);
  }

  /// Stubs `reset()` to complete successfully.
  void stubReset() {
    when(() => this.reset()).thenAnswer((_) => Future<void>.value());
  }

  /// Stubs `reset()` to throw [error].
  void stubResetThrows(Object error) {
    when(() => this.reset()).thenThrow(error);
  }

  /// Stubs `getFeatureFlag(definition)` to return [entity].
  void stubGetFeatureFlag({
    required AppFeatureFlagDefinition definition,
    required AppFeatureFlagEntity entity,
  }) {
    when(() => getFeatureFlag(definition)).thenReturn(entity);
  }

  /// Stubs `getFeatureFlag(definition)` to throw [error].
  void stubGetFeatureFlagThrows({
    required AppFeatureFlagDefinition definition,
    required Object error,
  }) {
    when(() => getFeatureFlag(definition)).thenThrow(error);
  }
}
