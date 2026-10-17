import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';

extension UserRoleExtension on UserRole {
  String title(BuildContext context) => switch (this) {
    UserRole.developer => context.localizations.onboardingRoleDeveloper,
    UserRole.recruiter => context.localizations.onboardingRoleRecruiter,
    UserRole.other => context.localizations.onboardingRoleOther,
  };

  String description(BuildContext context) => switch (this) {
    UserRole.developer =>
      context.localizations.onboardingRoleDeveloperDescription,
    UserRole.recruiter =>
      context.localizations.onboardingRoleRecruiterDescription,
    UserRole.other => context.localizations.onboardingRoleOtherDescription,
  };

  DSLottieIllustration get illustration => switch (this) {
    UserRole.developer => DSLottieIllustration.developerRole,
    UserRole.recruiter => DSLottieIllustration.recruiterRole,
    UserRole.other => DSLottieIllustration.explorerRole,
  };

  DSColor accent(BuildContext context) => switch (this) {
    UserRole.developer => context.colorPalette.brand.primary,
    UserRole.recruiter => context.colorPalette.brand.secondary,
    UserRole.other => context.colorPalette.brand.tertiary,
  };
}
