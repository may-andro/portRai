import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

import '../../../../../util/cv_export_test_fixture.dart';

class MockCvPdfRepository extends Mock implements CvPdfRepository {}

void registerCvPdfRepositoryFallbackValues() {
  registerFallbackValue(CvExportTestFixture.lightDocument());
  registerFallbackValue(const CvOptionsEntity());
  registerFallbackValue(CvExportTestFixture.labels);
  registerFallbackValue(Uint8List(0));
}

extension MockCvPdfRepositoryStub on MockCvPdfRepository {
  void stubGeneratePdf(Uint8List pdfBytes) {
    when(
      () => generatePdf(
        document: any(named: 'document'),
        options: any(named: 'options'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer((_) async => pdfBytes);
  }

  void stubGeneratePdfError(Object error) {
    when(
      () => generatePdf(
        document: any(named: 'document'),
        options: any(named: 'options'),
        labels: any(named: 'labels'),
      ),
    ).thenThrow(error);
  }

  void stubSharePdf({required bool isShared}) {
    when(
      () => sharePdf(
        pdfBytes: any(named: 'pdfBytes'),
        fileName: any(named: 'fileName'),
      ),
    ).thenAnswer((_) async => isShared);
  }

  void stubSharePdfError(Object error) {
    when(
      () => sharePdf(
        pdfBytes: any(named: 'pdfBytes'),
        fileName: any(named: 'fileName'),
      ),
    ).thenThrow(error);
  }
}
