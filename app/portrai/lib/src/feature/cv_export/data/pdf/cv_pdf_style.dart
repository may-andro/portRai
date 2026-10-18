import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;

/// Colors, fonts and text styles shared by every CV template.
class CvPdfStyle {
  CvPdfStyle({
    required int accentArgb,
    required this.fontScale,
    required this.regularFont,
    required this.boldFont,
    required this.italicFont,
  }) : accent = PdfColor.fromInt(accentArgb);

  factory CvPdfStyle.sans({
    required int accentArgb,
    required double fontScale,
  }) {
    return CvPdfStyle(
      accentArgb: accentArgb,
      fontScale: fontScale,
      regularFont: pdf_widgets.Font.helvetica(),
      boldFont: pdf_widgets.Font.helveticaBold(),
      italicFont: pdf_widgets.Font.helveticaOblique(),
    );
  }

  factory CvPdfStyle.serif({
    required int accentArgb,
    required double fontScale,
  }) {
    return CvPdfStyle(
      accentArgb: accentArgb,
      fontScale: fontScale,
      regularFont: pdf_widgets.Font.times(),
      boldFont: pdf_widgets.Font.timesBold(),
      italicFont: pdf_widgets.Font.timesItalic(),
    );
  }

  static const PdfColor ink = PdfColor.fromInt(0xFF1F2933);
  static const PdfColor muted = PdfColor.fromInt(0xFF616E7C);
  static const PdfColor white = PdfColors.white;

  final PdfColor accent;
  final double fontScale;
  final pdf_widgets.Font regularFont;
  final pdf_widgets.Font boldFont;
  final pdf_widgets.Font italicFont;

  /// A very light version of the accent, for backgrounds.
  PdfColor get tint => PdfColor(
    0.94 + accent.red * 0.06,
    0.94 + accent.green * 0.06,
    0.94 + accent.blue * 0.06,
  );

  /// A soft accent backdrop behind the cut-out profile photo.
  PdfColor get photoBackdrop => PdfColor(
    0.8 + accent.red * 0.2,
    0.8 + accent.green * 0.2,
    0.8 + accent.blue * 0.2,
  );

  pdf_widgets.TextStyle text({
    double size = 9,
    bool isBold = false,
    bool isItalic = false,
    PdfColor color = ink,
    double letterSpacing = 0,
    double lineSpacing = 1.5,
  }) {
    return pdf_widgets.TextStyle(
      font: isBold ? boldFont : (isItalic ? italicFont : regularFont),
      fontSize: size * fontScale,
      color: color,
      letterSpacing: letterSpacing,
      lineSpacing: lineSpacing,
    );
  }

  double scaled(double value) => value * fontScale;
}
