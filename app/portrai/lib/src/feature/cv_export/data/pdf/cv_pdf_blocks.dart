import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:portrai/src/feature/cv_export/data/pdf/cv_contact_icons.dart';
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

  pdf_widgets.Widget photo({required double size, PdfColor? borderColor}) {
    final borderWidth = _style.scaled(2.5);
    final photoSize = size - borderWidth * 2;
    return pdf_widgets.Container(
      width: size,
      height: size,
      decoration: pdf_widgets.BoxDecoration(
        shape: pdf_widgets.BoxShape.circle,
        border: pdf_widgets.Border.all(
          color: borderColor ?? _style.accent,
          width: borderWidth,
        ),
      ),
      padding: pdf_widgets.EdgeInsets.all(borderWidth),
      child: pdf_widgets.ClipOval(
        child: pdf_widgets.Image(
          pdf_widgets.MemoryImage(input.photo!),
          width: photoSize,
          height: photoSize,
          fit: pdf_widgets.BoxFit.cover,
        ),
      ),
    );
  }

  /// The contact entries; the languages entry follows the languages section
  /// toggle.
  List<CvContactEntity> get contacts => [
    for (final contact in input.document.contacts)
      if (contact.type != CvContactType.languages ||
          input.isShown(CvSection.languages))
        contact,
  ];

  pdf_widgets.Widget contact(
    CvContactEntity contact, {
    PdfColor color = CvPdfStyle.ink,
    double size = 8.5,
  }) {
    final iconSize = _style.scaled(size * 1.15);
    final text = pdf_widgets.Row(
      mainAxisSize: pdf_widgets.MainAxisSize.min,
      children: [
        pdf_widgets.SvgImage(
          svg: CvContactIcons.svgOf(contact.type, color),
          width: iconSize,
          height: iconSize,
        ),
        pdf_widgets.SizedBox(width: _style.scaled(4)),
        pdf_widgets.Text(
          contact.text,
          style: _style.text(size: size, color: color),
        ),
      ],
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

  /// A position with its employer, period and overview.
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
          _link(
            experience.url,
            pdf_widgets.Text(
              companyLine,
              style: _style.text(isBold: true, color: _style.accent),
            ),
          ),
          if (!isPeriodOnTop) periodText,
          pdf_widgets.SizedBox(height: _style.scaled(3)),
          if (experience.overview.isNotEmpty)
            pdf_widgets.Text(experience.overview, style: _style.text()),
        ],
      ),
    );
  }

  pdf_widgets.Widget _link(String? url, pdf_widgets.Widget child) {
    return url == null
        ? child
        : pdf_widgets.UrlLink(destination: url, child: child);
  }

  /// The experiences followed by a pointer to the website when some were
  /// left out.
  List<pdf_widgets.Widget> experiences({bool isPeriodOnTop = true}) {
    final document = input.document;
    final websiteUrl = document.websiteUrl;
    return [
      for (final experience in document.experiences)
        this.experience(experience, isPeriodOnTop: isPeriodOnTop),
      if (document.hasMoreExperiences && websiteUrl != null)
        _link(
          websiteUrl,
          pdf_widgets.Text(
            input.labels.moreExperienceLabel,
            style: _style
                .text(isItalic: true, color: _style.accent)
                .copyWith(decoration: pdf_widgets.TextDecoration.underline),
          ),
        ),
    ];
  }

  /// The projects as a compact list: a clickable name followed by its
  /// website and store links.
  pdf_widgets.Widget projectLinks() {
    const underline = pdf_widgets.TextDecoration.underline;
    return pdf_widgets.Wrap(
      spacing: _style.scaled(16),
      runSpacing: _style.scaled(5),
      children: [
        for (final project in input.document.projects)
          pdf_widgets.Row(
            mainAxisSize: pdf_widgets.MainAxisSize.min,
            children: [
              pdf_widgets.Container(
                width: _style.scaled(3),
                height: _style.scaled(3),
                margin: pdf_widgets.EdgeInsets.only(right: _style.scaled(5)),
                decoration: pdf_widgets.BoxDecoration(
                  color: _style.accent,
                  shape: pdf_widgets.BoxShape.circle,
                ),
              ),
              _link(
                project.links.first.url,
                pdf_widgets.Text(
                  project.title,
                  style: _style
                      .text(size: 9.5, isBold: true)
                      .copyWith(decoration: underline),
                ),
              ),
              for (final link in project.links)
                pdf_widgets.Padding(
                  padding: pdf_widgets.EdgeInsets.only(left: _style.scaled(4)),
                  child: _link(
                    link.url,
                    pdf_widgets.SvgImage(
                      svg: CvContactIcons.linkSvgOf(link.type, _style.accent),
                      width: _style.scaled(9),
                      height: _style.scaled(9),
                    ),
                  ),
                ),
            ],
          ),
      ],
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
}
