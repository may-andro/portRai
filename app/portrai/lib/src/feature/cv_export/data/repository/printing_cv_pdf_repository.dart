import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_renderer.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_photo_loader.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/exception/_exception.dart';
import 'package:portrai/src/feature/cv_export/domain/repository/_repository.dart';
import 'package:printing/printing.dart';

class _RenderRequest {
  const _RenderRequest({
    required this.document,
    required this.options,
    required this.labels,
    required this.photoBytes,
  });

  final CvDocumentEntity document;
  final CvOptionsEntity options;
  final CvLabelsEntity labels;
  final Uint8List? photoBytes;
}

class _RenderOutcome {
  const _RenderOutcome({this.pdfBytes, this.errorMessage});

  final Uint8List? pdfBytes;
  final String? errorMessage;
}

/// Runs on a background isolate so the many fit renders do not block the UI.
Future<_RenderOutcome> _renderInBackground(_RenderRequest request) async {
  try {
    final pdfBytes = await CvPdfRenderer().render(
      document: request.document,
      options: request.options,
      labels: request.labels,
      photoBytes: request.photoBytes,
    );
    return _RenderOutcome(pdfBytes: pdfBytes);
  } on CvPdfGenerationException catch (exception) {
    return _RenderOutcome(errorMessage: exception.message);
  }
}

@Register(as: CvPdfRepository)
class PrintingCvPdfRepository implements CvPdfRepository {
  PrintingCvPdfRepository(this._photoLoader);

  final CvPhotoLoader _photoLoader;
  String? _cachedPhotoUrl;
  Uint8List? _cachedPhotoBytes;

  @override
  Future<Uint8List> generatePdf({
    required CvDocumentEntity document,
    required CvOptionsEntity options,
    required CvLabelsEntity labels,
  }) async {
    final photoBytes = options.isPhotoIncluded
        ? await _photoBytesOf(document.photoUrl)
        : null;
    // On the web there are no isolates: compute then runs on the main thread.
    final outcome = await compute(
      _renderInBackground,
      _RenderRequest(
        document: document,
        options: options,
        labels: labels,
        photoBytes: photoBytes,
      ),
    );
    final pdfBytes = outcome.pdfBytes;
    if (pdfBytes == null) {
      throw CvPdfGenerationException(
        outcome.errorMessage ?? 'The CV could not be rendered.',
      );
    }
    return pdfBytes;
  }

  /// The photo is downloaded once and reused by every later render.
  Future<Uint8List?> _photoBytesOf(String url) async {
    if (url.isEmpty) return null;
    if (url == _cachedPhotoUrl) return _cachedPhotoBytes;
    final photoBytes = await _photoLoader.load(url);
    if (photoBytes != null) {
      _cachedPhotoUrl = url;
      _cachedPhotoBytes = photoBytes;
    }
    return photoBytes;
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
