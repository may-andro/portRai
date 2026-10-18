import 'dart:typed_data';

import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

abstract interface class CvPdfRepository {
  /// Renders [document] as a single page PDF.
  ///
  /// Throws a `CvPdfGenerationException` when it cannot be rendered.
  Future<Uint8List> generatePdf({
    required CvDocumentEntity document,
    required CvOptionsEntity options,
    required CvLabelsEntity labels,
  });

  /// Downloads (web) or shares (mobile and desktop) [pdfBytes].
  Future<bool> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
  });
}
