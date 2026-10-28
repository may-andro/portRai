import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/user/user.dart';

import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';

void main() {
  final portfolio = createPortfolioEntity();

  List<Type> sectionTypes(
    UserRole? role, {
    bool isCallBookingAvailable = false,
  }) => [
    for (final section in portfolio.sectionsFor(
      role,
      isCallBookingAvailable: isCallBookingAvailable,
    ))
      section.runtimeType,
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
        for (final isCallBookingAvailable in [false, true]) {
          final isInverse = [
            for (final type in sectionTypes(
              role,
              isCallBookingAvailable: isCallBookingAvailable,
            ).skip(1))
              if (type != BookCallSectionWidget) inverse.contains(type),
          ];
          for (var index = 0; index < isInverse.length; index++) {
            expect(
              isInverse[index],
              index.isEven,
              reason: 'role $role, booking $isCallBookingAvailable',
            );
          }
        }
      }
    });

    test('should offer booking a call after about for a recruiter when booking '
        'is on', () {
      final types = sectionTypes(
        UserRole.recruiter,
        isCallBookingAvailable: true,
      );

      expect(
        types.indexOf(BookCallSectionWidget),
        types.indexOf(AboutMeSectionWidget) + 1,
      );
      expect(
        sectionTypes(UserRole.recruiter),
        isNot(contains(BookCallSectionWidget)),
      );
    });

    test('should not offer booking a call to other roles', () {
      for (final role in [UserRole.developer, UserRole.other, null]) {
        expect(
          sectionTypes(role, isCallBookingAvailable: true),
          isNot(contains(BookCallSectionWidget)),
          reason: 'role $role',
        );
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
