import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

sealed class BuildCvDocumentFailure extends BasicFailure {
  const BuildCvDocumentFailure({super.cause});
}

@Localizable('errorCvDataUnavailable')
class CvDataUnavailableFailure extends BuildCvDocumentFailure {
  const CvDataUnavailableFailure({super.cause});
}

@Localizable('errorCvUnknown')
class UnknownBuildCvDocumentFailure extends BuildCvDocumentFailure {
  const UnknownBuildCvDocumentFailure({super.cause});
}

/// Composes the portfolio data into the content of a CV.
@register
class BuildCvDocumentUseCase
    extends BaseNoParamUseCase<CvDocumentEntity, BuildCvDocumentFailure> {
  BuildCvDocumentUseCase(
    this._getProfileUseCase,
    this._getExperiencesUseCase,
    this._getProjectsUseCase,
    this._getAllExpertiseUseCase,
  );

  static const int _maxSocialLinks = 3;
  static const List<String> _skillLevelOrder = [
    'expert',
    'advanced',
    'intermediate',
    'familiar',
  ];

  final GetProfileUseCase _getProfileUseCase;
  final GetExperiencesUseCase _getExperiencesUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final GetAllExpertiseUseCase _getAllExpertiseUseCase;

  @protected
  @override
  Future<Either<BuildCvDocumentFailure, CvDocumentEntity>> execute() async {
    final profileEither = await _getProfileUseCase();
    if (profileEither.isLeft) {
      return Left(CvDataUnavailableFailure(cause: profileEither.left));
    }
    final experiencesEither = await _getExperiencesUseCase();
    if (experiencesEither.isLeft) {
      return Left(CvDataUnavailableFailure(cause: experiencesEither.left));
    }
    final projectsEither = await _getProjectsUseCase();
    if (projectsEither.isLeft) {
      return Left(CvDataUnavailableFailure(cause: projectsEither.left));
    }
    final expertiseEither = await _getAllExpertiseUseCase();
    if (expertiseEither.isLeft) {
      return Left(CvDataUnavailableFailure(cause: expertiseEither.left));
    }

    return Right(
      _buildDocument(
        profile: profileEither.right,
        experiences: experiencesEither.right,
        projects: projectsEither.right,
        expertiseList: expertiseEither.right,
      ),
    );
  }

  CvDocumentEntity _buildDocument({
    required ProfileEntity profile,
    required List<ExperienceEntity> experiences,
    required List<ProjectEntity> projects,
    required List<ExpertiseEntity> expertiseList,
  }) {
    final location = [
      profile.location.city,
      profile.location.country,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    final sortedExperiences = [...experiences]
      ..sort((first, second) => second.startDate.compareTo(first.startDate));
    final sortedProjects = [...projects]
      ..sort((first, second) => second.startDate.compareTo(first.startDate));

    return CvDocumentEntity(
      fullName: profile.fullName,
      title: profile.title,
      summary: profile.summary,
      photoUrl: profile.profileImage,
      contacts: [
        if (profile.email.isNotEmpty)
          CvContactEntity(text: profile.email, url: 'mailto:${profile.email}'),
        if (profile.phone.isNotEmpty)
          CvContactEntity(text: profile.phone, url: 'tel:${profile.phone}'),
        if (location.isNotEmpty) CvContactEntity(text: location),
        for (final socialLink in profile.socialLinks.take(_maxSocialLinks))
          CvContactEntity(
            text: socialLink.url.replaceFirst(
              RegExp('^https?://(www\\.)?'),
              '',
            ),
            url: socialLink.url,
          ),
      ],
      experiences: [
        for (final experience in sortedExperiences)
          CvExperienceEntity(
            position: experience.position,
            company: experience.company,
            location: experience.location,
            startDate: experience.startDate,
            endDate: experience.current ? null : experience.endDate,
            highlights: _highlightsOf(experience),
          ),
      ],
      projects: [
        for (final project in sortedProjects)
          CvProjectEntity(
            title: project.title,
            role: project.role,
            description: project.description,
            technologies: project.technologies,
          ),
      ],
      skillGroups: [
        for (final expertise in expertiseList)
          if (expertise.skills.isNotEmpty)
            CvSkillGroupEntity(
              title: expertise.title,
              skills: _skillNamesByLevel(expertise),
            ),
      ],
      educations: [
        for (final education in profile.educations)
          CvEducationEntity(
            degree: [
              education.degree,
              education.field,
            ].where((part) => part.trim().isNotEmpty).join(', '),
            institution: education.institution,
            period: [
              education.startDate,
              education.endDate,
            ].where((part) => part.trim().isNotEmpty).join(' - '),
          ),
      ],
      languages: [
        for (final language in profile.languages)
          CvLanguageEntity(
            name: language.language,
            proficiency: language.proficiency,
          ),
      ],
    );
  }

  List<String> _highlightsOf(ExperienceEntity experience) {
    final highlights = [
      ...experience.achievements,
      ...experience.responsibilities,
    ].where((highlight) => highlight.trim().isNotEmpty).toList();
    if (highlights.isNotEmpty) return highlights;
    return experience.description.trim().isEmpty
        ? const []
        : [experience.description];
  }

  List<String> _skillNamesByLevel(ExpertiseEntity expertise) {
    final sortedSkills = [...expertise.skills]
      ..sort(
        (first, second) =>
            _rankOf(first.level).compareTo(_rankOf(second.level)),
      );
    return [for (final skill in sortedSkills) skill.name];
  }

  int _rankOf(String? level) {
    final levelIndex = _skillLevelOrder.indexOf(level ?? '');
    return levelIndex == -1 ? _skillLevelOrder.length : levelIndex;
  }

  @protected
  @override
  BuildCvDocumentFailure mapErrorToFailure(Object e, StackTrace st) {
    return UnknownBuildCvDocumentFailure(cause: e);
  }
}
