import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:module_injector/module_injector.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_blocks.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/bold_cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/classic_cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/minimal_cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/sidebar_cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/exception/_exception.dart';

/// Renders a [CvDocumentEntity] with the selected template, trimming the
/// content step by step until it fits a single A4 page.
@register
class CvPdfRenderer {
  static const double _maxFontScale = 1.4;
  static const double _fontScaleStep = 0.02;
  static const String _fallbackLocaleCode = 'en';

  CvPdfTemplate _templateOf(CvTemplate template) {
    return switch (template) {
      CvTemplate.sidebar => const SidebarCvPdfTemplate(),
      CvTemplate.classic => const ClassicCvPdfTemplate(),
      CvTemplate.minimal => const MinimalCvPdfTemplate(),
      CvTemplate.bold => const BoldCvPdfTemplate(),
    };
  }

  Future<Uint8List> render({
    required CvDocumentEntity document,
    required CvOptionsEntity options,
    required CvLabelsEntity labels,
    required Uint8List? photoBytes,
  }) async {
    final template = _templateOf(options.template);
    final dateFormat = await _createDateFormat(labels.localeCode);
    final validPhotoBytes = _isRenderableImage(photoBytes) ? photoBytes : null;

    Object? lastError;
    for (final level in CvFitLevelEntity.levels) {
      final fittedDocument = document.fit(level);
      // Start large so a short CV fills the page, and shrink until it fits.
      final isFullContent = level == CvFitLevelEntity.levels.first;
      for (final fontScale in _fontScalesFor(level, isFullContent)) {
        try {
          final input = CvPdfInput(
            document: fittedDocument,
            options: options,
            labels: labels,
            style: template.createStyle(
              accentArgb: options.accent.argb,
              fontScale: fontScale,
            ),
            photo: validPhotoBytes,
            dateFormat: dateFormat,
          );
          final pdfDocument = pdf_widgets.Document(
            title: document.fullName,
            author: document.fullName,
          )..addPage(template.build(input));
          final pdfBytes = await pdfDocument.save();
          if (pdfDocument.document.pdfPageList.pages.length == 1) {
            return pdfBytes;
          }
        } on Exception catch (exception) {
          // A layout that cannot fit the page throws: try a smaller one.
          lastError = exception;
        }
      }
    }
    throw CvPdfGenerationException(
      'The CV does not fit a single page.',
      cause: lastError,
    );
  }

  List<double> _fontScalesFor(CvFitLevelEntity level, bool isFullContent) {
    // Only the full content is enlarged; trimmed levels exist to make it fit.
    final largestFontScale = isFullContent ? _maxFontScale : 1.0;
    return [
      for (
        var fontScale = largestFontScale;
        fontScale > level.fontScale;
        fontScale -= _fontScaleStep
      )
        fontScale,
      level.fontScale,
    ];
  }

  Future<DateFormat> _createDateFormat(String localeCode) async {
    await initializeDateFormatting(localeCode);
    final verifiedLocale = Intl.verifiedLocale(
      localeCode,
      DateFormat.localeExists,
      onFailure: (_) => _fallbackLocaleCode,
    )!;
    await initializeDateFormatting(verifiedLocale);
    return DateFormat('MMM yyyy', verifiedLocale);
  }

  bool _isRenderableImage(Uint8List? bytes) {
    if (bytes == null) return false;
    try {
      pdf_widgets.MemoryImage(bytes);
      return true;
    } on Exception {
      return false;
    }
  }
}
