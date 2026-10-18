import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_photo_loader.dart';
import 'package:portrai/src/feature/cv_export/data/repository/printing_cv_pdf_repository.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  group('PrintingCvPdfRepository', () {
    test('should return a pdf rendered on a background isolate when '
        'generating', () async {
      final repository = PrintingCvPdfRepository(CvPhotoLoader());

      final pdfBytes = await repository.generatePdf(
        document: CvExportTestFixture.lightDocument(),
        options: const CvOptionsEntity(),
        labels: CvExportTestFixture.labels,
      );

      expect(latin1.decode(pdfBytes.sublist(0, 4)), '%PDF');
    });
  });
}
