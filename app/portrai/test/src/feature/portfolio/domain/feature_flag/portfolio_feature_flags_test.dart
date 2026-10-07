import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/domain/feature_flag/portfolio_feature_flags.dart';

void main() {
  group('PortfolioFeatureFlags', () {
    test('should expose every portfolio definition when all is read', () {
      expect(PortfolioFeatureFlags.all, [
        PortfolioFeatureFlags.testimonialsSection,
        PortfolioFeatureFlags.experiencesSection,
        PortfolioFeatureFlags.servicesSection,
        PortfolioFeatureFlags.projectsSection,
        PortfolioFeatureFlags.expertiesSection,
      ]);
    });

    test('should define the testimonials section metadata when accessed', () {
      expect(
        PortfolioFeatureFlags.testimonialsSection.key,
        'feature_testimonials_section',
      );
      expect(PortfolioFeatureFlags.testimonialsSection.defaultValue, isFalse);
      expect(
        PortfolioFeatureFlags.testimonialsSection.displayName,
        'Testimonials Section',
      );
    });

    test('should define the expertise section metadata when accessed', () {
      expect(
        PortfolioFeatureFlags.expertiesSection.key,
        'feature_experties_section',
      );
      expect(PortfolioFeatureFlags.expertiesSection.defaultValue, isFalse);
      expect(
        PortfolioFeatureFlags.expertiesSection.description,
        'Enables the experties section on portfolio page',
      );
    });
  });
}
