import 'package:feature_flag/feature_flag.dart';
import 'package:mocktail/mocktail.dart';

class MockFeatureFlagController extends Mock implements FeatureFlagController {}

extension MockFeatureFlagControllerStub on MockFeatureFlagController {
  /// Stubs `getAllFeatureFlags()` to return [flags].
  void stubGetAllFeatureFlags(List<FeatureFlag> flags) {
    when(() => getAllFeatureFlags()).thenReturn(flags);
  }

  /// Stubs `getAllFeatureFlags()` to throw [error].
  void stubGetAllFeatureFlagsThrows(Object error) {
    when(() => getAllFeatureFlags()).thenThrow(error);
  }

  /// Stubs `isFeatureEnabled(key)` to return [isEnabled].
  void stubIsFeatureEnabled({required String key, required bool isEnabled}) {
    when(() => isFeatureEnabled(key)).thenReturn(isEnabled);
  }

  /// Stubs `isFeatureEnabled(key)` to throw [error].
  void stubIsFeatureEnabledThrows({
    required String key,
    required Object error,
  }) {
    when(() => isFeatureEnabled(key)).thenThrow(error);
  }

  /// Stubs `updateFeatureFlag(flag)` to complete successfully.
  void stubUpdateFeatureFlag(FeatureFlag flag) {
    when(() => updateFeatureFlag(flag)).thenAnswer((_) async {});
  }

  /// Stubs `updateFeatureFlag(flag)` to throw [error].
  void stubUpdateFeatureFlagThrows({
    required FeatureFlag flag,
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
}
