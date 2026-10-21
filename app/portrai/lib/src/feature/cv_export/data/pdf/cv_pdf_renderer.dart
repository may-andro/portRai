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

/// The content and font scale chosen to fill one page. It depends on
/// everything but the accent, so a new accent reuses it.
class CvPdfLayout {
  const CvPdfLayout({required this.document, required this.fontScale});

  final CvDocumentEntity document;
  final double fontScale;
}

class CvPdfRendering {
  const CvPdfRendering({required this.pdfBytes, required this.layout});

  final Uint8List pdfBytes;
  final CvPdfLayout layout;
}

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

  /// Renders [layout] when given, otherwise searches for the fullest layout
  /// that fits one page first.
  ///
  /// The search only lays pages out, which is enough to count them; painting
  /// and encoding the PDF happen once, for the chosen layout.
  Future<CvPdfRendering> render({
    required CvDocumentEntity document,
    required CvOptionsEntity options,
    required CvLabelsEntity labels,
    required Uint8List? photoBytes,
    CvPdfLayout? layout,
  }) async {
    final template = _templateOf(options.template);
    final dateFormat = await _createDateFormat(labels.localeCode);
    final validPhotoBytes = _isRenderableImage(photoBytes) ? photoBytes : null;

    pdf_widgets.Document layOut(CvPdfLayout layout) {
      final input = CvPdfInput(
        document: layout.document,
        options: options,
        labels: labels,
        style: template.createStyle(
          accentArgb: options.accent.argb,
          fontScale: layout.fontScale,
        ),
        photo: validPhotoBytes,
        dateFormat: dateFormat,
      );
      return pdf_widgets.Document(
        title: document.fullName,
        author: document.fullName,
      )..addPage(template.build(input));
    }

    final chosenLayout =
        layout ??
        await _fullestLayout(
          document: document,
          template: template,
          layOut: layOut,
        );
    final pdfBytes = await layOut(chosenLayout).save();
    return CvPdfRendering(pdfBytes: pdfBytes, layout: chosenLayout);
  }

  Future<CvPdfLayout> _fullestLayout({
    required CvDocumentEntity document,
    required CvPdfTemplate template,
    required pdf_widgets.Document Function(CvPdfLayout layout) layOut,
  }) async {
    Object? lastError;
    Future<bool> fits(CvDocumentEntity fittedDocument, double fontScale) async {
      // Lets the UI repaint between the layouts (no isolates on web).
      await Future<void>.delayed(Duration.zero);
      try {
        final pdfDocument = layOut(
          CvPdfLayout(document: fittedDocument, fontScale: fontScale),
        );
        // MultiPage lays its content out when the page is added.
        return pdfDocument.document.pdfPageList.pages.length == 1;
      } on Exception catch (exception) {
        // A layout that cannot fit the page throws: treat it as not fitting.
        lastError = exception;
        return false;
      }
    }

    // Fitting is monotonic: less content always fits better. The main content
    // and the skills column are searched independently, as one of them is
    // often full while the other still has room.
    final levels = CvFitLevelEntity.levels;
    final mostCompactLevel = levels.last;

    // The fullest index in [0, count) that fits, or null when none does.
    Future<int?> fullestFit(
      int count,
      Future<bool> Function(int index) attempt,
    ) async {
      int? fullest;
      var low = 0;
      var high = count - 1;
      while (low <= high) {
        final middle = (low + high) ~/ 2;
        if (await attempt(middle)) {
          fullest = middle;
          high = middle - 1;
        } else {
          low = middle + 1;
        }
      }
      return fullest;
    }

    Future<CvPdfLayout> enlarged(
      CvDocumentEntity fittedDocument,
      CvFitLevelEntity level,
    ) async {
      final fontScales = _enlargedFontScales(level);
      final enlargedIndex = await fullestFit(
        fontScales.length,
        (index) => fits(fittedDocument, fontScales[index]),
      );
      return CvPdfLayout(
        document: fittedDocument,
        fontScale: enlargedIndex == null
            ? level.fontScale
            : fontScales[enlargedIndex],
      );
    }

    if (template.hasSkillsColumn) {
      final contentIndex = await fullestFit(
        levels.length,
        (index) => fits(
          document.fit(levels[index], skillsLevel: mostCompactLevel),
          levels[index].fontScale,
        ),
      );
      if (contentIndex != null) {
        final contentLevel = levels[contentIndex];
        final skillsIndex = await fullestFit(
          levels.length,
          (index) => fits(
            document.fit(contentLevel, skillsLevel: levels[index]),
            contentLevel.fontScale,
          ),
        );
        final skillsLevel = levels[skillsIndex ?? levels.length - 1];
        return await enlarged(
          document.fit(contentLevel, skillsLevel: skillsLevel),
          contentLevel,
        );
      }
    } else {
      // Everything shares one flow: keep the short overviews so the skills are
      // not trimmed, and only use the detailed ones when all of it still fits.
      final contentIndex = await fullestFit(
        levels.length,
        (index) => fits(
          document.fit(levels[index], useDetailedOverview: false),
          levels[index].fontScale,
        ),
      );
      if (contentIndex != null) {
        final contentLevel = levels[contentIndex];
        var fittedDocument = document.fit(
          contentLevel,
          useDetailedOverview: false,
        );
        if (contentIndex == 0) {
          final detailedDocument = document.fit(contentLevel);
          if (await fits(detailedDocument, contentLevel.fontScale)) {
            fittedDocument = detailedDocument;
          }
        }
        return await enlarged(fittedDocument, contentLevel);
      }
    }
    throw CvPdfGenerationException(
      'The CV does not fit a single page.',
      cause: lastError,
    );
  }

  /// Font scales above the level's own, from the largest to the smallest.
  List<double> _enlargedFontScales(CvFitLevelEntity level) {
    return [
      for (
        var fontScale = _maxFontScale;
        fontScale > level.fontScale;
        fontScale -= _fontScaleStep
      )
        fontScale,
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
