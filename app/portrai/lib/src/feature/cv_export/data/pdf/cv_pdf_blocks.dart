import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_pdf_style.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

/// Everything a template needs to lay out one CV.
class CvPdfInput {
  CvPdfInput({
    required this.document,
    required this.options,
    required this.labels,
    required this.style,
    required this.photo,
    required this.dateFormat,
  });

  final CvDocumentEntity document;
  final CvOptionsEntity options;
  final CvLabelsEntity labels;
  final CvPdfStyle style;
  final Uint8List? photo;
  final DateFormat dateFormat;

  bool isShown(CvSection section) => options.sections.contains(section);

  bool get isPhotoShown => options.isPhotoIncluded && photo != null;
}

/// Content blocks reused by the templates, which only differ in layout and
/// in how headings and entries are decorated.
class CvPdfBlocks {
  const CvPdfBlocks(this.input);

  final CvPdfInput input;

  CvPdfStyle get _style => input.style;

  String period(CvExperienceEntity experience) {
    final end = experience.endDate;
    final endText = end == null
        ? input.labels.presentLabel
        : input.dateFormat.format(end);
    return '${input.dateFormat.format(experience.startDate)} - $endText';
  }

  pdf_widgets.Widget photo({required double size}) {
    return pdf_widgets.ClipOval(
      child: pdf_widgets.Image(
        pdf_widgets.MemoryImage(input.photo!),
        width: size,
        height: size,
        fit: pdf_widgets.BoxFit.cover,
      ),
    );
  }

  pdf_widgets.Widget contact(
    CvContactEntity contact, {
    PdfColor color = CvPdfStyle.ink,
    double size = 8.5,
  }) {
    final text = pdf_widgets.Text(
      contact.text,
      style: _style.text(size: size, color: color),
    );
    final url = contact.url;
    return url == null
        ? text
        : pdf_widgets.UrlLink(destination: url, child: text);
  }

  pdf_widgets.Widget summary({
    PdfColor color = CvPdfStyle.ink,
    double size = 9.5,
  }) {
    return pdf_widgets.Text(
      input.document.summary,
      style: _style.text(size: size, color: color, lineSpacing: 2),
    );
  }

  /// A position with its employer, period and highlights.
  pdf_widgets.Widget experience(
    CvExperienceEntity experience, {
    bool isPeriodOnTop = true,
  }) {
    final periodText = pdf_widgets.Text(
      period(experience),
      style: _style.text(size: 8.5, color: CvPdfStyle.muted),
    );
    final companyLine = [
      experience.company,
      experience.location,
    ].where((part) => part.trim().isNotEmpty).join(' · ');

    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(bottom: _style.scaled(9)),
      child: pdf_widgets.Column(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          if (isPeriodOnTop)
            pdf_widgets.Row(
              mainAxisAlignment: pdf_widgets.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [
                pdf_widgets.Expanded(
                  child: pdf_widgets.Text(
                    experience.position,
                    style: _style.text(size: 10.5, isBold: true),
                  ),
                ),
                periodText,
              ],
            )
          else
            pdf_widgets.Text(
              experience.position,
              style: _style.text(size: 10.5, isBold: true),
            ),
          pdf_widgets.Text(
            companyLine,
            style: _style.text(isBold: true, color: _style.accent),
          ),
          if (!isPeriodOnTop) periodText,
          pdf_widgets.SizedBox(height: _style.scaled(3)),
          for (final highlight in experience.highlights) bullet(highlight),
        ],
      ),
    );
  }

  pdf_widgets.Widget bullet(String text, {double size = 9}) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(bottom: _style.scaled(1.5)),
      child: pdf_widgets.Row(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          pdf_widgets.Container(
            width: _style.scaled(9),
            padding: pdf_widgets.EdgeInsets.only(
              top: _style.scaled(size * 0.4),
            ),
            alignment: pdf_widgets.Alignment.topLeft,
            child: pdf_widgets.Container(
              width: _style.scaled(3),
              height: _style.scaled(3),
              decoration: pdf_widgets.BoxDecoration(
                color: _style.accent,
                shape: pdf_widgets.BoxShape.circle,
              ),
            ),
          ),
          pdf_widgets.Expanded(
            child: pdf_widgets.Text(text, style: _style.text(size: size)),
          ),
        ],
      ),
    );
  }

  pdf_widgets.Widget project(CvProjectEntity project) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(bottom: _style.scaled(8)),
      child: pdf_widgets.Column(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          pdf_widgets.RichText(
            text: pdf_widgets.TextSpan(
              children: [
                pdf_widgets.TextSpan(
                  text: project.title,
                  style: _style.text(size: 10, isBold: true),
                ),
                if (project.role.trim().isNotEmpty)
                  pdf_widgets.TextSpan(
                    text: '  ${project.role}',
                    style: _style.text(size: 8.5, color: CvPdfStyle.muted),
                  ),
              ],
            ),
          ),
          pdf_widgets.Text(project.description, style: _style.text()),
          if (project.technologies.isNotEmpty)
            pdf_widgets.Text(
              project.technologies.join(' · '),
              style: _style.text(size: 8, isBold: true, color: _style.accent),
            ),
        ],
      ),
    );
  }

  pdf_widgets.Widget skillGroup(
    CvSkillGroupEntity group, {
    PdfColor color = CvPdfStyle.ink,
  }) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(bottom: _style.scaled(6)),
      child: pdf_widgets.Column(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          pdf_widgets.Text(
            group.title,
            style: _style.text(size: 8.5, isBold: true, color: color),
          ),
          pdf_widgets.Text(
            group.skills.join(', '),
            style: _style.text(size: 8.5, color: color),
          ),
        ],
      ),
    );
  }

  pdf_widgets.Widget education(
    CvEducationEntity education, {
    PdfColor color = CvPdfStyle.ink,
  }) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(bottom: _style.scaled(5)),
      child: pdf_widgets.Column(
        crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
        children: [
          pdf_widgets.Text(
            education.degree,
            style: _style.text(isBold: true, color: color),
          ),
          pdf_widgets.Text(
            education.institution,
            style: _style.text(size: 8.5, color: color),
          ),
          if (education.period.isNotEmpty)
            pdf_widgets.Text(
              education.period,
              style: _style.text(
                size: 8,
                color: color == CvPdfStyle.ink ? CvPdfStyle.muted : color,
              ),
            ),
        ],
      ),
    );
  }

  pdf_widgets.Widget language(
    CvLanguageEntity language, {
    PdfColor color = CvPdfStyle.ink,
  }) {
    return pdf_widgets.Padding(
      padding: pdf_widgets.EdgeInsets.only(bottom: _style.scaled(2)),
      child: pdf_widgets.RichText(
        text: pdf_widgets.TextSpan(
          children: [
            pdf_widgets.TextSpan(
              text: language.name,
              style: _style.text(size: 8.5, isBold: true, color: color),
            ),
            pdf_widgets.TextSpan(
              text: '  ${language.proficiency}',
              style: _style.text(size: 8.5, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
