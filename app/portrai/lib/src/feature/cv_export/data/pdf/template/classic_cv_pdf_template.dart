import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_blocks.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_style.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

/// A traditional single column CV with a serif font and a centered header.
class ClassicCvPdfTemplate extends CvPdfTemplate {
  const ClassicCvPdfTemplate();

  @override
  CvPdfStyle createStyle({required int accentArgb, required double fontScale}) {
    return CvPdfStyle.serif(accentArgb: accentArgb, fontScale: fontScale);
  }

  @override
  bool get hasSkillsColumn => false;

  @override
  pdf_widgets.Page build(CvPdfInput input) {
    final document = input.document;
    final style = input.style;
    final labels = input.labels;
    final blocks = CvPdfBlocks(input);

    return pdf_widgets.MultiPage(
      pageTheme: const pdf_widgets.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pdf_widgets.EdgeInsets.fromLTRB(40, 36, 40, 32),
      ),
      build: (_) => [
        pdf_widgets.Row(
          children: [
            if (input.isPhotoShown) ...[
              blocks.photo(size: 72),
              pdf_widgets.SizedBox(width: style.scaled(16)),
            ],
            pdf_widgets.Expanded(
              child: pdf_widgets.Column(
                children: [
                  pdf_widgets.Text(
                    document.fullName,
                    textAlign: pdf_widgets.TextAlign.center,
                    style: style.text(size: 26, isBold: true, lineSpacing: 1),
                  ),
                  pdf_widgets.SizedBox(height: style.scaled(2)),
                  pdf_widgets.Text(
                    document.title,
                    textAlign: pdf_widgets.TextAlign.center,
                    style: style.text(
                      size: 12,
                      isItalic: true,
                      color: style.accent,
                    ),
                  ),
                  pdf_widgets.SizedBox(height: style.scaled(5)),
                  pdf_widgets.Wrap(
                    alignment: pdf_widgets.WrapAlignment.center,
                    spacing: style.scaled(12),
                    runSpacing: style.scaled(2),
                    children: [
                      for (final contact in blocks.contacts)
                        blocks.contact(contact),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (input.isShown(CvSection.summary) &&
            document.summary.isNotEmpty) ...[
          _heading(style, labels.summaryHeading),
          blocks.summary(),
        ],
        if (input.isShown(CvSection.experience) &&
            document.experiences.isNotEmpty) ...[
          _heading(style, labels.experienceHeading),
          ...blocks.experiences(),
        ],
        if (input.isShown(CvSection.projects) &&
            document.projects.isNotEmpty) ...[
          _heading(style, labels.projectsHeading),
          blocks.projectLinks(),
        ],
        if (input.isShown(CvSection.skills) &&
            document.skillGroups.isNotEmpty) ...[
          _heading(style, labels.skillsHeading),
          for (final group in document.skillGroups) blocks.skillGroup(group),
        ],
        if (input.isShown(CvSection.education) &&
            document.educations.isNotEmpty) ...[
          _heading(style, labels.educationHeading),
          for (final education in document.educations)
            blocks.education(education),
        ],
      ],
    );
  }

  pdf_widgets.Widget _heading(CvPdfStyle style, String text) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(
        top: style.scaled(12),
        bottom: style.scaled(6),
      ),
      child: pdf_widgets.Column(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          pdf_widgets.Text(
            text.toUpperCase(),
            style: style.text(
              size: 11,
              isBold: true,
              color: style.accent,
              letterSpacing: 1,
            ),
          ),
          pdf_widgets.SizedBox(height: style.scaled(2)),
          pdf_widgets.Container(height: 0.8, color: style.accent),
        ],
      ),
    );
  }
}
