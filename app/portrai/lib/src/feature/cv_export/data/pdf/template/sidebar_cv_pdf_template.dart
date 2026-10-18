import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_blocks.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_style.dart';
import 'package:portrai/src/feature/cv_export/data/pdf/template/cv_pdf_template.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

/// A tinted left column with contact, skills and education next to the
/// main content.
class SidebarCvPdfTemplate extends CvPdfTemplate {
  const SidebarCvPdfTemplate();

  static const double _sidebarWidth = 190;

  @override
  bool get hasSkillsColumn => true;

  @override
  pdf_widgets.Page build(CvPdfInput input) {
    final style = input.style;
    final blocks = CvPdfBlocks(input);

    return pdf_widgets.MultiPage(
      pageTheme: pdf_widgets.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pdf_widgets.EdgeInsets.zero,
        buildBackground: (_) => pdf_widgets.Row(
          children: [
            pdf_widgets.Container(
              width: _sidebarWidth,
              height: PdfPageFormat.a4.height,
              color: style.tint,
            ),
          ],
        ),
      ),
      build: (_) => [
        pdf_widgets.Row(
          crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
          children: [
            pdf_widgets.Container(
              width: _sidebarWidth,
              padding: const pdf_widgets.EdgeInsets.fromLTRB(18, 30, 18, 24),
              child: _sidebar(input, blocks),
            ),
            pdf_widgets.Expanded(
              child: pdf_widgets.Padding(
                padding: const pdf_widgets.EdgeInsets.fromLTRB(24, 30, 30, 24),
                child: _main(input, blocks),
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
        top: style.scaled(10),
        bottom: style.scaled(5),
      ),
      child: pdf_widgets.Text(
        text.toUpperCase(),
        style: style.text(
          isBold: true,
          color: style.accent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  pdf_widgets.Widget _sidebar(CvPdfInput input, CvPdfBlocks blocks) {
    final document = input.document;
    final style = input.style;
    final labels = input.labels;

    return pdf_widgets.Column(
      crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
      children: [
        if (input.isPhotoShown) ...[
          pdf_widgets.Center(child: blocks.photo(size: 100)),
          pdf_widgets.SizedBox(height: style.scaled(6)),
        ],
        _heading(style, labels.contactHeading),
        for (final contact in blocks.contacts)
          pdf_widgets.Padding(
            padding: pdf_widgets.EdgeInsets.only(bottom: style.scaled(3)),
            child: blocks.contact(contact),
          ),
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

  pdf_widgets.Widget _main(CvPdfInput input, CvPdfBlocks blocks) {
    final document = input.document;
    final style = input.style;
    final labels = input.labels;

    return pdf_widgets.Column(
      crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
      children: [
        pdf_widgets.Text(
          document.fullName,
          style: style.text(size: 26, isBold: true, lineSpacing: 1),
        ),
        pdf_widgets.SizedBox(height: style.scaled(2)),
        pdf_widgets.Text(
          document.title,
          style: style.text(size: 12, color: style.accent, isBold: true),
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
      ],
    );
  }
}
