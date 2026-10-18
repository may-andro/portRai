import 'dart:typed_data';

import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_renderer.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_photo_loader.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/exception/_exception.dart';
import 'package:portrai/src/feature/cv_export/domain/repository/_repository.dart';
import 'package:printing/printing.dart';

@Register(as: CvPdfRepository)
class PrintingCvPdfRepository implements CvPdfRepository {
  PrintingCvPdfRepository(this._renderer, this._photoLoader);

  final CvPdfRenderer _renderer;
  final CvPhotoLoader _photoLoader;

  @override
  Future<Uint8List> generatePdf({
    required CvDocumentEntity document,
    required CvOptionsEntity options,
    required CvLabelsEntity labels,
  }) async {
    final photoBytes = options.isPhotoIncluded && document.photoUrl.isNotEmpty
        ? await _photoLoader.load(document.photoUrl)
        : null;
    return await _renderer.render(
      document: document,
      options: options,
      labels: labels,
      photoBytes: photoBytes,
    );
  }

  @override
  Future<bool> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      return await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } on Exception catch (exception) {
      throw CvPdfShareException(
        'The PDF could not be shared.',
        cause: exception,
      );
    }
  }
}
