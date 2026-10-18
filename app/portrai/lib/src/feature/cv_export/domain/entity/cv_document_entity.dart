import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_contact_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_education_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_experience_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_fit_level_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_language_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_project_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_skill_group_entity.dart';

class CvDocumentEntity extends Equatable {
  const CvDocumentEntity({
    required this.fullName,
    required this.title,
    required this.summary,
    required this.photoUrl,
    required this.contacts,
    required this.experiences,
    required this.projects,
    required this.skillGroups,
    required this.educations,
    required this.languages,
    this.websiteUrl,
    this.hasMoreExperiences = false,
  });

  final String fullName;
  final String title;
  final String summary;
  final String photoUrl;
  final List<CvContactEntity> contacts;
  final List<CvExperienceEntity> experiences;
  final List<CvProjectEntity> projects;
  final List<CvSkillGroupEntity> skillGroups;
  final List<CvEducationEntity> educations;
  final List<CvLanguageEntity> languages;

  /// The portfolio website with the full experience and details.
  final String? websiteUrl;

  /// Whether experiences were left out of this document.
  final bool hasMoreExperiences;

  /// Returns a copy trimmed to [level], keeping the most relevant content:
  /// experiences and projects are already ordered most recent first.
  CvDocumentEntity fit(CvFitLevelEntity level) {
    return CvDocumentEntity(
      fullName: _clean(fullName),
      title: _clean(title),
      summary: _truncate(summary, level.maxSummaryLength),
      photoUrl: photoUrl,
      websiteUrl: websiteUrl,
      hasMoreExperiences:
          hasMoreExperiences || experiences.length > level.maxExperiences,
      contacts: [
        for (final contact in contacts)
          CvContactEntity(text: _clean(contact.text), url: contact.url),
      ],
      experiences: [
        for (final experience in experiences.take(level.maxExperiences))
          CvExperienceEntity(
            position: _clean(experience.position),
            company: _clean(experience.company),
            location: _clean(experience.location),
            startDate: experience.startDate,
            endDate: experience.endDate,
            url: experience.url,
            highlights: [
              for (final highlight in experience.highlights.take(
                level.maxHighlightsPerExperience,
              ))
                _truncate(highlight, level.maxHighlightLength),
            ],
          ),
      ],
      projects: [
        for (final project in projects.take(level.maxProjects))
          CvProjectEntity(
            title: _clean(project.title),
            role: _clean(project.role),
            description: _truncate(
              project.description,
              level.maxProjectDescriptionLength,
            ),
            technologies: project.technologies.take(6).map(_clean).toList(),
            url: project.url,
          ),
      ],
      skillGroups: [
        for (final group in skillGroups.take(level.maxSkillGroups))
          CvSkillGroupEntity(
            title: _clean(group.title),
            skills: group.skills
                .take(level.maxSkillsPerGroup)
                .map(_clean)
                .toList(),
          ),
      ],
      educations: [
        for (final education in educations.take(level.maxEducations))
          CvEducationEntity(
            degree: _clean(education.degree),
            institution: _clean(education.institution),
            period: _clean(education.period),
          ),
      ],
      languages: [
        for (final language in languages.take(level.maxLanguages))
          CvLanguageEntity(
            name: _clean(language.name),
            proficiency: _clean(language.proficiency),
          ),
      ],
    );
  }

  /// The PDF base fonts only cover Latin-1, so common typographic characters
  /// are replaced by their plain equivalents to avoid missing-glyph boxes.
  static String _clean(String text) {
    return text
        .replaceAll(RegExp('[\u2010-\u2015\u2212]'), '-')
        .replaceAll(RegExp('[\u2018\u2019\u201B]'), "'")
        .replaceAll(RegExp('[\u201C\u201D\u201F]'), '"')
        .replaceAll('\u2026', '...')
        .replaceAll(RegExp('[\u2022\u25CF\u25AA]'), '-')
        .replaceAll(RegExp('[\u00A0\u2007\u202F]'), ' ');
  }

  static String _truncate(String text, int maxLength) {
    final trimmedText = _clean(text).trim();
    if (trimmedText.length <= maxLength) return trimmedText;
    final cutText = trimmedText.substring(0, maxLength - 1);
    final lastSpaceIndex = cutText.lastIndexOf(' ');
    final wordSafeText = lastSpaceIndex > maxLength ~/ 2
        ? cutText.substring(0, lastSpaceIndex)
        : cutText;
    return '${wordSafeText.trimRight()}...';
  }

  @override
  List<Object?> get props => [
    fullName,
    title,
    summary,
    photoUrl,
    contacts,
    experiences,
    projects,
    skillGroups,
    educations,
    languages,
    websiteUrl,
    hasMoreExperiences,
  ];
}
