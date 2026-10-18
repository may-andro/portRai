import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';
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

    // Ongoing positions come first, the finished ones follow by start date.
    final sortedExperiences = [...experiences]
      ..sort((first, second) {
        if (first.current != second.current) return first.current ? -1 : 1;
        return second.startDate.compareTo(first.startDate);
      });
    final sortedProjects = [...projects]
      ..sort((first, second) => second.startDate.compareTo(first.startDate));

    return CvDocumentEntity(
      fullName: profile.fullName,
      title: profile.title,
      summary: profile.summary,
      photoUrl: profile.profileImage,
      contacts: [
        if (profile.email.isNotEmpty)
          CvContactEntity(
            text: profile.email,
            url: 'mailto:${profile.email}',
            type: CvContactType.email,
          ),
        if (profile.phone.isNotEmpty)
          CvContactEntity(
            text: profile.phone,
            url: 'tel:${profile.phone}',
            type: CvContactType.phone,
          ),
        if (location.isNotEmpty)
          CvContactEntity(text: location, type: CvContactType.location),
        if (_languageCodesOf(profile) case final codes when codes.isNotEmpty)
          CvContactEntity(
            text: codes.join(', '),
            type: CvContactType.languages,
          ),
        for (final socialLink in profile.socialLinks.take(_maxSocialLinks))
          CvContactEntity(
            text: socialLink.url.replaceFirst(
              RegExp('^https?://(www\\.)?'),
              '',
            ),
            url: socialLink.url,
            type: _contactTypeOf(socialLink.url),
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
            url: _validUrl(experience.url),
            overview: _overviewOf(experience),
            detailedOverview: experience.longDescription,
          ),
      ],
      websiteUrl: _websiteUrlOf(profile),
      projects: [
        for (final project in sortedProjects)
          if (!_isDeprecated(project)) ..._projectEntriesOf(project),
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
    );
  }

  List<String> _languageCodesOf(ProfileEntity profile) {
    final codes = <String>[];
    for (final language in profile.languages) {
      final code = CvLanguageCode.ofLanguage(language);
      if (!codes.contains(code)) codes.add(code);
    }
    return codes;
  }

  CvContactType _contactTypeOf(String url) {
    final lowerCaseUrl = url.toLowerCase();
    if (lowerCaseUrl.contains('github.com')) return CvContactType.github;
    if (lowerCaseUrl.contains('linkedin.com')) return CvContactType.linkedin;
    return CvContactType.website;
  }

  String? _validUrl(String? url) {
    final trimmedUrl = url?.trim();
    if (trimmedUrl == null || !trimmedUrl.startsWith('http')) return null;
    return trimmedUrl;
  }

  String? _websiteUrlOf(ProfileEntity profile) {
    for (final published in profile.publishedAt) {
      if (published.name.toLowerCase() == 'website') {
        final url = _validUrl(published.url);
        if (url != null) return url;
      }
    }
    for (final socialLink in profile.socialLinks) {
      if (socialLink.name.toLowerCase() == 'portfolio') {
        final url = _validUrl(socialLink.url);
        if (url != null) return url;
      }
    }
    return null;
  }

  bool _isDeprecated(ProjectEntity project) {
    return project.status.trim().toLowerCase() == 'deprecated';
  }

  /// One entry per distinct store listing, so markets sharing the same app
  /// produce a single entry. Projects without a store link are left out. The
  /// country codes are appended to the title only when the project has
  /// several distinct listings.
  List<CvProjectEntity> _projectEntriesOf(ProjectEntity project) {
    final marketsByStoreLinks = <String, List<ProjectMarketEntity>>{};
    for (final market in project.markets) {
      final appStore = _validUrl(market.appStore);
      final playStore = _validUrl(market.playStore);
      if (appStore == null && playStore == null) continue;
      marketsByStoreLinks
          .putIfAbsent('$appStore|$playStore', () => [])
          .add(market);
    }

    final hasSeveralListings = marketsByStoreLinks.length > 1;
    return [
      for (final markets in marketsByStoreLinks.values)
        CvProjectEntity(
          title: hasSeveralListings
              ? '${project.title} ${_countryCodesOf(markets)}'
              : project.title,
          role: project.role,
          description: project.description,
          technologies: project.technologies,
          links: _linksOf(markets),
        ),
    ];
  }

  String _countryCodesOf(List<ProjectMarketEntity> markets) {
    final codes = <String>{
      for (final market in markets) CvCountryCode.ofMarket(market),
    };
    return codes.join('/');
  }

  /// The first website of the markets followed by their shared store links.
  List<CvProjectLinkEntity> _linksOf(List<ProjectMarketEntity> markets) {
    final website = markets
        .map((market) => _validUrl(market.website))
        .whereType<String>()
        .firstOrNull;
    final market = markets.first;
    return [
      for (final (type, url) in [
        (CvProjectLinkType.web, website),
        (CvProjectLinkType.ios, _validUrl(market.appStore)),
        (CvProjectLinkType.android, _validUrl(market.playStore)),
      ])
        if (url != null) CvProjectLinkEntity(type: type, url: url),
    ];
  }

  /// The short description, or the achievements and responsibilities joined
  /// into one paragraph when the experience has no description.
  String _overviewOf(ExperienceEntity experience) {
    final description = experience.description.trim();
    if (description.isNotEmpty) return description;
    return [
      ...experience.achievements,
      ...experience.responsibilities,
    ].map((item) => item.trim()).where((item) => item.isNotEmpty).join('. ');
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
