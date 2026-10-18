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
      try {
        final input = CvPdfInput(
          document: document.fit(level),
          options: options,
          labels: labels,
          style: template.createStyle(
            accentArgb: options.accent.argb,
            fontScale: level.fontScale,
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
        // A layout that cannot fit the page throws: try the next, smaller level.
        lastError = exception;
      }
    }
    throw CvPdfGenerationException(
      'The CV does not fit a single page.',
      cause: lastError,
    );
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
