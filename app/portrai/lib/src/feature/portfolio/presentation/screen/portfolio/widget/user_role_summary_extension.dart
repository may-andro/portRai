import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/profile/profile.dart';

extension UserRoleSummaryExtension on UserRole? {
  /// Picks the professional summary variant for the role. The switch is
  /// exhaustive, so a new role must choose its variant here.
  ProfessionalSummaryVariant summaryVariant(PortfolioEntity portfolio) {
    return switch (this) {
      UserRole.developer => EngineeringProfessionalSummary(
        stack: [
          for (final expertise in portfolio.expertises) ...expertise.skillNames,
        ],
      ),
      UserRole.recruiter => const HiringProfessionalSummary(),
      UserRole.other || null => const OverviewProfessionalSummary(),
    };
  }
}
