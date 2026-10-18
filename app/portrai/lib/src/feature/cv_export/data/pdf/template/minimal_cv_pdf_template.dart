import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_blocks.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_style.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

/// A calm, airy layout: headings sit in a narrow left gutter and the
/// content in a wide right column.
class MinimalCvPdfTemplate extends CvPdfTemplate {
  const MinimalCvPdfTemplate();

  static const double _gutterWidth = 92;

  @override
  pdf_widgets.Page build(CvPdfInput input) {
    final document = input.document;
    final style = input.style;
    final labels = input.labels;
    final blocks = CvPdfBlocks(input);

    return pdf_widgets.MultiPage(
      pageTheme: const pdf_widgets.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pdf_widgets.EdgeInsets.fromLTRB(44, 40, 44, 36),
      ),
      build: (_) => [
        pdf_widgets.Row(
          children: [
            pdf_widgets.Expanded(
              child: pdf_widgets.Column(
                crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
                children: [
                  pdf_widgets.Text(
                    document.fullName,
                    style: style.text(size: 24, isBold: true, lineSpacing: 1),
                  ),
                  pdf_widgets.SizedBox(height: style.scaled(2)),
                  pdf_widgets.Text(
                    document.title,
                    style: style.text(size: 11.5, color: CvPdfStyle.muted),
                  ),
                  pdf_widgets.SizedBox(height: style.scaled(6)),
                  pdf_widgets.Wrap(
                    spacing: style.scaled(14),
                    runSpacing: style.scaled(2),
                    children: [
                      for (final contact in document.contacts)
                        blocks.contact(contact, color: CvPdfStyle.muted),
                    ],
                  ),
                ],
              ),
            ),
            if (input.isPhotoShown) blocks.photo(size: 70),
          ],
        ),
        pdf_widgets.SizedBox(height: style.scaled(12)),
        pdf_widgets.Container(height: 2, width: 36, color: style.accent),
        if (input.isShown(CvSection.summary) && document.summary.isNotEmpty)
          _row(style, labels.summaryHeading, blocks.summary()),
        if (input.isShown(CvSection.experience) &&
            document.experiences.isNotEmpty)
          _row(
            style,
            labels.experienceHeading,
            pdf_widgets.Column(
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [...blocks.experiences(isPeriodOnTop: false)],
            ),
          ),
        if (input.isShown(CvSection.projects) && document.projects.isNotEmpty)
          _row(
            style,
            labels.projectsHeading,
            pdf_widgets.Column(
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [blocks.projectLinks()],
            ),
          ),
        if (input.isShown(CvSection.skills) && document.skillGroups.isNotEmpty)
          _row(
            style,
            labels.skillsHeading,
            pdf_widgets.Column(
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [
                for (final group in document.skillGroups)
                  blocks.skillGroup(group),
              ],
            ),
          ),
        if (input.isShown(CvSection.education) &&
            document.educations.isNotEmpty)
          _row(
            style,
            labels.educationHeading,
            pdf_widgets.Column(
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [
                for (final education in document.educations)
                  blocks.education(education),
              ],
            ),
          ),
        if (input.isShown(CvSection.languages) && document.languages.isNotEmpty)
          _row(
            style,
            labels.languagesHeading,
            pdf_widgets.Wrap(
              spacing: style.scaled(16),
              children: [
                for (final language in document.languages)
                  blocks.language(language),
              ],
            ),
          ),
      ],
    );
  }

  pdf_widgets.Widget _row(
    CvPdfStyle style,
    String heading,
    pdf_widgets.Widget content,
  ) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(top: style.scaled(12)),
      child: pdf_widgets.Row(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          pdf_widgets.SizedBox(
            width: _gutterWidth,
            child: pdf_widgets.Text(
              heading.toUpperCase(),
              style: style.text(
                size: 8.5,
                isBold: true,
                color: style.accent,
                letterSpacing: 1.2,
              ),
            ),
          ),
          pdf_widgets.Expanded(child: content),
        ],
      ),
    );
  }
}
