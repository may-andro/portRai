import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `portfolio` feature.
abstract final class PortfolioFeatureFlags {
  static const testimonialsSection = AppFeatureFlagDefinition(
    key: 'feature_testimonials_section',
    defaultValue: false,
    displayName: 'Testimonials Section',
    description: 'Enables the testimonials section on portfolio page',
  );

  static const experiencesSection = AppFeatureFlagDefinition(
    key: 'feature_experiences_section',
    defaultValue: false,
    displayName: 'Experiences Section',
    description: 'Enables the experience section on portfolio page',
  );

  static const servicesSection = AppFeatureFlagDefinition(
    key: 'feature_services_section',
    defaultValue: false,
    displayName: 'Services Section',
    description: 'Enables the services section on portfolio page',
  );

  static const projectsSection = AppFeatureFlagDefinition(
    key: 'feature_projects_section',
    defaultValue: false,
    displayName: 'Projects Section',
    description: 'Enables the projects section on portfolio page',
  );

  static const expertiesSection = AppFeatureFlagDefinition(
    key: 'feature_experties_section',
    defaultValue: false,
    displayName: 'Experties Section',
    description: 'Enables the experties section on portfolio page',
  );

  static const all = [
    testimonialsSection,
    experiencesSection,
    servicesSection,
    projectsSection,
    expertiesSection,
  ];
}
