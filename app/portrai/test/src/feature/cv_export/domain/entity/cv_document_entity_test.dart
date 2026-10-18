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
          experience.highlights.length,
          lessThanOrEqualTo(level.maxHighlightsPerExperience),
        );
      }
    });

    test('should keep only the last three experiences and flag the rest', () {
      final fitted = document.fit(CvFitLevelEntity.levels.first);

      expect(fitted.experiences.length, 3);
      expect(fitted.hasMoreExperiences, isTrue);
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
      const original = CvLanguageEntity(
        name: 'Dutch \u2013 NL',
        proficiency: 'Native\u2019s',
      );
      const withLanguage = CvDocumentEntity(
        fullName: 'Ada \u2014 Lovelace',
        title: 'Title',
        summary: 'Multi\u2011flavor \u201Cquoted\u201D',
        photoUrl: '',
        contacts: [],
        experiences: [],
        projects: [],
        skillGroups: [],
        educations: [],
        languages: [original],
      );

      final fitted = withLanguage.fit(CvFitLevelEntity.levels.first);

      expect(fitted.fullName, 'Ada - Lovelace');
      expect(fitted.summary, 'Multi-flavor "quoted"');
      expect(fitted.languages.single.name, 'Dutch - NL');
      expect(fitted.languages.single.proficiency, "Native's");
    });
  });
}
