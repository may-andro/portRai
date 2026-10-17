import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';

import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';

void main() {
  final portfolio = createPortfolioEntity();

  List<Type> sectionTypes(UserRole? role) => [
    for (final section in portfolio.sectionsFor(role)) section.runtimeType,
  ];

  group('PortfolioExtension.sectionsFor', () {
    test('should keep the default order when there is no role', () {
      expect(sectionTypes(null), sectionTypes(UserRole.other));
      expect(sectionTypes(null).first, IntroSectionWidget);
    });

    test('should lead with expertise then projects for a developer', () {
      final types = sectionTypes(UserRole.developer);

      expect(types.first, IntroSectionWidget);
      expect(types.sublist(1, 3), [
        ExpertiseSectionWidget,
        ProjectsSectionWidget,
      ]);
    });

    test('should lead with expertise then experience for a recruiter', () {
      final types = sectionTypes(UserRole.recruiter);

      expect(types.first, IntroSectionWidget);
      expect(types.sublist(1, 3), [
        ExpertiseSectionWidget,
        ExperienceSectionWidget,
      ]);
    });

    test('should alternate inverse and surface backgrounds for every role', () {
      const inverse = {
        ExpertiseSectionWidget,
        ServicesSectionWidget,
        AboutMeSectionWidget,
      };

      for (final role in [...UserRole.values, null]) {
        final isInverse = [
          for (final type in sectionTypes(role).skip(1)) inverse.contains(type),
        ];
        for (var index = 0; index < isInverse.length; index++) {
          expect(isInverse[index], index.isEven, reason: 'role $role');
        }
      }
    });

    test('should contain the same sections for every role', () {
      final expected = sectionTypes(null).toSet();

      for (final role in UserRole.values) {
        final types = sectionTypes(role);
        expect(types.toSet(), expected);
        expect(types.length, expected.length);
      }
    });
  });
}
