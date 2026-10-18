import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  group('CvDocumentEntity.fit', () {
    final document = CvExportTestFixture.heavyDocument();

    test('should keep the first content when the level caps the lists', () {
      final level = CvFitLevelEntity.levels.last;

      final fitted = document.fit(level);

      expect(
        fitted.experiences.length,
        lessThanOrEqualTo(level.maxExperiences),
      );
      expect(fitted.projects.length, lessThanOrEqualTo(level.maxProjects));
      expect(
        fitted.experiences.first.company,
        document.experiences.first.company,
      );
      for (final experience in fitted.experiences) {
        expect(
          experience.overview.length,
          lessThanOrEqualTo(level.maxOverviewLength + 3),
        );
      }
    });

    test('should keep only the last three experiences and flag the rest', () {
      final fitted = document.fit(CvFitLevelEntity.levels.first);

      expect(fitted.experiences.length, 3);
      expect(fitted.hasMoreExperiences, isTrue);
    });

    test('should trim the skills to their own level when one is given', () {
      final fitted = document.fit(
        CvFitLevelEntity.levels.first,
        skillsLevel: CvFitLevelEntity.levels.last,
      );

      expect(
        fitted.skillGroups.length,
        CvFitLevelEntity.levels.last.maxSkillGroups,
      );
      expect(
        fitted.experiences.first.overview.length,
        greaterThan(CvFitLevelEntity.levels.last.maxOverviewLength + 3),
      );
    });

    test('should use the detailed overview only when it fits the level', () {
      final experience = CvExperienceEntity(
        position: 'Engineer',
        company: 'Company',
        location: '',
        startDate: DateTime(2020),
        endDate: null,
        overview: 'Short overview.',
        detailedOverview: 'Detailed overview. ' * 10,
      );
      final withExperience = CvDocumentEntity(
        fullName: 'Ada',
        title: 'Title',
        summary: '',
        photoUrl: '',
        contacts: const [],
        experiences: [experience],
        projects: const [],
        skillGroups: const [],
        educations: const [],
      );

      final roomy = withExperience.fit(CvFitLevelEntity.levels.first);
      final compact = withExperience.fit(CvFitLevelEntity.levels.last);

      expect(roomy.experiences.single.overview, startsWith('Detailed'));
      expect(compact.experiences.single.overview, 'Short overview.');
    });

    test('should truncate the summary with dots when it is too long', () {
      final level = CvFitLevelEntity.levels.last;

      final fitted = document.fit(level);

      expect(
        fitted.summary.length,
        lessThanOrEqualTo(level.maxSummaryLength + 3),
      );
      expect(fitted.summary, endsWith('...'));
    });

    test('should replace typographic characters when the text has them', () {
      const withTypography = CvDocumentEntity(
        fullName: 'Ada \u2014 Lovelace',
        title: 'Title',
        summary: 'Multi\u2011flavor \u201Cquoted\u201D',
        photoUrl: '',
        contacts: [],
        experiences: [],
        projects: [],
        skillGroups: [],
        educations: [],
      );

      final fitted = withTypography.fit(CvFitLevelEntity.levels.first);

      expect(fitted.fullName, 'Ada - Lovelace');
      expect(fitted.summary, 'Multi-flavor "quoted"');
    });
  });
}
