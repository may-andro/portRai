import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_renderer.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  group('CvPdfRenderer', () {
    final renderer = CvPdfRenderer();

    int pageCountOf(Uint8List pdfBytes) {
      final pdfText = latin1.decode(pdfBytes, allowInvalid: true);
      return RegExp(r'/Type\s*/Page(?![a-z])').allMatches(pdfText).length;
    }

    for (final template in CvTemplate.values) {
      test('should render a single page when the ${template.name} template '
          'gets more content than fits', () async {
        final pdfBytes = await renderer.render(
          document: CvExportTestFixture.heavyDocument(),
          options: CvOptionsEntity(template: template),
          labels: CvExportTestFixture.labels,
          photoBytes: null,
        );

        expect(latin1.decode(pdfBytes.sublist(0, 4)), '%PDF');
        expect(pageCountOf(pdfBytes), 1);
      });

      test('should render a single page when the ${template.name} template '
          'gets little content', () async {
        final pdfBytes = await renderer.render(
          document: CvExportTestFixture.lightDocument(),
          options: CvOptionsEntity(template: template),
          labels: CvExportTestFixture.labels,
          photoBytes: null,
        );

        expect(pageCountOf(pdfBytes), 1);
      });
    }

    test('should render when every section is hidden', () async {
      final pdfBytes = await renderer.render(
        document: CvExportTestFixture.heavyDocument(),
        options: const CvOptionsEntity(sections: {}),
        labels: CvExportTestFixture.labels,
        photoBytes: null,
      );

      expect(pageCountOf(pdfBytes), 1);
    });

    test(
      'should render without the photo when the photo is not an image',
      () async {
        final pdfBytes = await renderer.render(
          document: CvExportTestFixture.lightDocument(),
          options: const CvOptionsEntity(isPhotoIncluded: true),
          labels: CvExportTestFixture.labels,
          photoBytes: Uint8List.fromList([1, 2, 3]),
        );

        expect(pageCountOf(pdfBytes), 1);
      },
    );

    test(
      'should fall back to english dates when the locale is unknown',
      () async {
        final pdfBytes = await renderer.render(
          document: CvExportTestFixture.lightDocument(),
          options: const CvOptionsEntity(),
          labels: const CvLabelsEntity(
            localeCode: 'xx_invalid',
            presentLabel: 'Present',
            summaryHeading: 'Summary',
            experienceHeading: 'Experience',
            projectsHeading: 'Projects',
            skillsHeading: 'Skills',
            educationHeading: 'Education',
            languagesHeading: 'Languages',
            contactHeading: 'Contact',
            moreExperienceLabel: 'See all experience on my website',
          ),
          photoBytes: null,
        );

        expect(pageCountOf(pdfBytes), 1);
      },
    );
  });
}
