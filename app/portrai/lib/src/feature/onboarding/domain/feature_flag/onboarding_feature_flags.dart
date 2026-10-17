import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `onboarding` feature.
abstract final class OnboardingFeatureFlags {
  static const roleOnboarding = AppFeatureFlagDefinition(
    key: 'feature_role_onboarding',
    defaultValue: false,
    displayName: 'Role Onboarding',
    description:
        'Asks first-time users for their role before the portfolio page.',
  );

  static const all = [roleOnboarding];
}
