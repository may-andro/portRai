import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_blocks.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_style.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

/// A full-width accent colored banner followed by a two column body.
class BoldCvPdfTemplate extends CvPdfTemplate {
  const BoldCvPdfTemplate();

  static const double _sideColumnWidth = 170;

  @override
  pdf_widgets.Page build(CvPdfInput input) {
    final document = input.document;
    final style = input.style;
    final labels = input.labels;
    final blocks = CvPdfBlocks(input);

    return pdf_widgets.MultiPage(
      pageTheme: const pdf_widgets.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pdf_widgets.EdgeInsets.zero,
      ),
      build: (_) => [
        pdf_widgets.Container(
          width: double.infinity,
          color: style.accent,
          padding: const pdf_widgets.EdgeInsets.fromLTRB(32, 30, 32, 22),
          child: pdf_widgets.Row(
            children: [
              pdf_widgets.Expanded(
                child: pdf_widgets.Column(
                  crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
                  children: [
                    pdf_widgets.Text(
                      document.fullName,
                      style: style.text(
                        size: 30,
                        isBold: true,
                        color: CvPdfStyle.white,
                        lineSpacing: 1,
                      ),
                    ),
                    pdf_widgets.SizedBox(height: style.scaled(3)),
                    pdf_widgets.Text(
                      document.title,
                      style: style.text(size: 13, color: CvPdfStyle.white),
                    ),
                    pdf_widgets.SizedBox(height: style.scaled(8)),
                    pdf_widgets.Wrap(
                      spacing: style.scaled(14),
                      runSpacing: style.scaled(2),
                      children: [
                        for (final contact in blocks.contacts)
                          blocks.contact(contact, color: CvPdfStyle.white),
                      ],
                    ),
                  ],
                ),
              ),
              if (input.isPhotoShown) ...[
                pdf_widgets.SizedBox(width: style.scaled(16)),
                blocks.photo(size: 84, borderColor: CvPdfStyle.white),
              ],
            ],
          ),
        ),
        pdf_widgets.Row(
          crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
          children: [
            pdf_widgets.Expanded(
              child: pdf_widgets.Padding(
                padding: const pdf_widgets.EdgeInsets.fromLTRB(32, 6, 22, 24),
                child: pdf_widgets.Column(
                  crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
            ),
            pdf_widgets.Container(
              width: _sideColumnWidth,
              padding: const pdf_widgets.EdgeInsets.fromLTRB(14, 6, 28, 24),
              child: pdf_widgets.Column(
                crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
                children: [
                  if (input.isShown(CvSection.skills) &&
                      document.skillGroups.isNotEmpty) ...[
                    _heading(style, labels.skillsHeading),
                    for (final group in document.skillGroups)
                      blocks.skillGroup(group),
                  ],
                  if (input.isShown(CvSection.education) &&
                      document.educations.isNotEmpty) ...[
                    _heading(style, labels.educationHeading),
                    for (final education in document.educations)
                      blocks.education(education),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pdf_widgets.Widget _heading(CvPdfStyle style, String text) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(
        top: style.scaled(12),
        bottom: style.scaled(6),
      ),
      child: pdf_widgets.Row(
        children: [
          pdf_widgets.Container(
            width: 4,
            height: style.scaled(12),
            color: style.accent,
          ),
          pdf_widgets.SizedBox(width: style.scaled(6)),
          pdf_widgets.Text(
            text.toUpperCase(),
            style: style.text(size: 10, isBold: true, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}
