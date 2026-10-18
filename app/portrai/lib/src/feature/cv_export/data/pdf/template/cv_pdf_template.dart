import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_blocks.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_style.dart';

/// A CV layout. Templates are stateless and render one A4 page.
abstract class CvPdfTemplate {
  const CvPdfTemplate();

  /// Whether the skills sit in a column of their own next to the main content.
  /// Otherwise everything shares one flow, so long experience texts compete
  /// with the skills for space.
  bool get hasSkillsColumn;

  CvPdfStyle createStyle({required int accentArgb, required double fontScale}) {
    return CvPdfStyle.sans(accentArgb: accentArgb, fontScale: fontScale);
  }

  /// Builds the page. A template must lay out as a single page; the renderer
  /// treats extra pages and layout overflow as "content does not fit".
  pdf_widgets.Page build(CvPdfInput input);
}
