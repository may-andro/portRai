import 'package:portrai/src/feature/cv_export/domain/entity/cv_contact_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_document_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_education_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_experience_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_labels_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_project_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_project_link_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_skill_group_entity.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/profile/domain/entity/availability_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/coordinates_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/education_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/language_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/location_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/published_at_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/resume_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/social_link_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/working_hours_entity.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';
import 'package:portrai/src/feature/project/project.dart';

/// Deterministic portfolio and CV content for the CV export tests.
class CvExportTestFixture {
  const CvExportTestFixture._();

  static const CvLabelsEntity labels = CvLabelsEntity(
    localeCode: 'en',
    presentLabel: 'Present',
    summaryHeading: 'Summary',
    experienceHeading: 'Experience',
    projectsHeading: 'Projects',
    skillsHeading: 'Skills',
    educationHeading: 'Education',
    contactHeading: 'Contact',
    moreExperienceLabel: 'See all experience on my website',
  );

  static ProfileEntity profile() {
    return const ProfileEntity(
      fullName: 'Ada Lovelace',
      title: 'Senior Flutter Developer',
      subtitle: 'Mobile engineer',
      email: 'ada@example.com',
      phone: '+34 600 000 000',
      profileImage: 'https://example.com/ada.png',
      coverImage: '',
      summary: 'Mobile engineer building scalable cross-platform apps.',
      detailedBio: '',
      elevatorPitch: '',
      uniqueValueProposition: '',
      publishedAt: [
        PublishedAtEntity(
          name: 'Website',
          url: 'https://ada.example.com',
          image: '',
        ),
      ],
      resume: ResumeEntity(url: '', lastUpdated: '', image: ''),
      socialLinks: [
        SocialLinkEntity(
          name: 'GitHub',
          url: 'https://www.github.com/ada',
          image: '',
        ),
      ],
      availability: AvailabilityEntity(
        status: '',
        workType: '',
        openToRelocate: false,
        preferredProjectDuration: '',
        hourlyRate: '',
        availability: '',
      ),
      workingHours: WorkingHoursEntity(
        timezone: '',
        preferredHours: '',
        weekdays: true,
        weekends: '',
      ),
      currentRole: 'Tech Lead',
      currentCompany: 'Analytical Engines',
      yearsOfExperience: 10,
      projectsDelivered: 20,
      location: LocationEntity(
        city: 'Madrid',
        state: '',
        country: 'Spain',
        timezone: '',
        coordinates: CoordinatesEntity(latitude: 0, longitude: 0),
      ),
      languages: [
        LanguageEntity(language: 'English', proficiency: 'Fluent'),
        LanguageEntity(language: 'Spanish', proficiency: 'Native'),
      ],
      educations: [
        EducationEntity(
          institution: 'University of London',
          degree: 'BSc',
          field: 'Mathematics',
          startDate: '2008',
          endDate: '2012',
          image: '',
          url: '',
          location: '',
        ),
      ],
    );
  }

  static List<ExperienceEntity> experiences() {
    return [
      _experience(
        company: 'Old Company',
        startDate: DateTime(2015, 3),
        endDate: DateTime(2018, 6),
        achievements: ['Shipped the first release'],
      ),
      _experience(
        company: 'Current Company',
        startDate: DateTime(2022),
        endDate: null,
        isCurrent: true,
        achievements: ['Led a team of six engineers', 'Cut build time by 40%'],
        responsibilities: ['Code reviews'],
      ),
      _experience(
        company: 'Middle Company',
        startDate: DateTime(2018, 7),
        endDate: DateTime(2021, 12),
        description: 'Built mobile apps.',
      ),
    ];
  }

  static List<ProjectEntity> projects() {
    return [
      _project(
        title: 'Old Project',
        startDate: DateTime(2016),
        markets: [_market('ES', playStore: 'https://play.example.com/old')],
      ),
      _project(
        title: 'New Project',
        startDate: DateTime(2023),
        markets: [
          _market(
            'ES',
            website: 'https://new.example.com',
            appStore: 'https://apps.apple.com/app/new',
          ),
        ],
      ),
      _project(
        title: 'Shared Project',
        startDate: DateTime(2022),
        markets: [
          _market('Germany', appStore: 'https://apps.example.com/shared'),
          _market(
            'Austria',
            website: 'https://shared.example.com',
            appStore: 'https://apps.example.com/shared',
          ),
        ],
      ),
      _project(
        title: 'Multi Project',
        startDate: DateTime(2021),
        markets: [
          _market('Germany', playStore: 'https://play.example.com/de'),
          _market('Spain', playStore: 'https://play.example.com/es'),
        ],
      ),
      _project(
        title: 'Web Only Project',
        startDate: DateTime(2020),
        markets: [_market('ES', website: 'https://web.example.com')],
      ),
      _project(title: 'Unlinked Project', startDate: DateTime(2019)),
      _project(
        title: 'Old Deprecated Project',
        startDate: DateTime(2014),
        status: 'Deprecated',
        markets: [_market('ES', playStore: 'https://play.example.com/dep')],
      ),
    ];
  }

  static ProjectMarketEntity _market(
    String country, {
    String? website,
    String? appStore,
    String? playStore,
  }) {
    return ProjectMarketEntity(
      country: country,
      latitude: 0,
      longitude: 0,
      website: website,
      appStore: appStore,
      playStore: playStore,
    );
  }

  static List<ExpertiseEntity> expertise() {
    return const [
      ExpertiseEntity(
        image: '',
        title: 'Mobile',
        skills: [
          SkillEntity(name: 'Dart', level: 'familiar'),
          SkillEntity(name: 'Flutter', level: 'expert'),
          SkillEntity(name: 'Kotlin'),
          SkillEntity(name: 'Swift', level: 'advanced'),
        ],
      ),
      ExpertiseEntity(image: '', title: 'Empty', skills: []),
    ];
  }

  /// A document with far more content than fits a page, to exercise fitting.
  static CvDocumentEntity heavyDocument() {
    final longText = List.filled(
      6,
      'Designed and delivered a modular mobile architecture used by millions',
    ).join(' ');

    return CvDocumentEntity(
      fullName: 'Ada Lovelace',
      title: 'Senior Flutter & Android Developer',
      summary: List.filled(8, longText).join(' '),
      photoUrl: 'https://example.com/ada.png',
      websiteUrl: 'https://ada.example.com',
      contacts: const [
        CvContactEntity(text: 'ada@example.com', url: 'mailto:ada@example.com'),
        CvContactEntity(text: '+34 600 000 000', url: 'tel:+34600000000'),
        CvContactEntity(text: 'Madrid, Spain'),
        CvContactEntity(text: 'github.com/ada', url: 'https://github.com/ada'),
      ],
      experiences: [
        for (var index = 0; index < 8; index++)
          CvExperienceEntity(
            position: 'Senior Engineer $index',
            company: 'Company $index',
            location: 'Madrid, Spain',
            startDate: DateTime(2024 - index * 2),
            endDate: index == 0 ? null : DateTime(2025 - index * 2),
            url: 'https://company$index.example.com',
            highlights: [for (var item = 0; item < 6; item++) longText],
          ),
      ],
      projects: [
        for (var index = 0; index < 6; index++)
          CvProjectEntity(
            title: 'Project $index',
            role: 'Lead developer',
            description: longText,
            technologies: const ['Flutter', 'Dart', 'Firebase', 'Kotlin'],
            links: [
              CvProjectLinkEntity(
                type: CvProjectLinkType.web,
                url: 'https://project$index.example.com',
              ),
            ],
          ),
      ],
      skillGroups: [
        for (var index = 0; index < 8; index++)
          CvSkillGroupEntity(
            title: 'Group $index',
            skills: [for (var item = 0; item < 12; item++) 'Skill $item'],
          ),
      ],
      educations: const [
        CvEducationEntity(
          degree: 'BSc, Mathematics',
          institution: 'University of London',
          period: '2008 - 2012',
        ),
        CvEducationEntity(
          degree: 'MSc, Computer Science',
          institution: 'University of Cambridge',
          period: '2012 - 2014',
        ),
        CvEducationEntity(
          degree: 'Certificate, Flutter',
          institution: 'Google',
          period: '2019',
        ),
      ],
    );
  }

  /// A small document that comfortably fits a page.
  static CvDocumentEntity lightDocument() {
    return CvDocumentEntity(
      fullName: 'Ada Lovelace',
      title: 'Developer',
      summary: 'Mobile engineer.',
      photoUrl: '',
      contacts: const [CvContactEntity(text: 'ada@example.com')],
      experiences: [
        CvExperienceEntity(
          position: 'Engineer',
          company: 'Analytical Engines',
          location: 'London',
          startDate: DateTime(2020),
          endDate: null,
          highlights: const ['Built things'],
        ),
      ],
      projects: const [],
      skillGroups: const [
        CvSkillGroupEntity(title: 'Mobile', skills: ['Flutter']),
      ],
      educations: const [],
    );
  }

  static ExperienceEntity _experience({
    required String company,
    required DateTime startDate,
    required DateTime? endDate,
    bool isCurrent = false,
    String description = '',
    List<String> achievements = const [],
    List<String> responsibilities = const [],
  }) {
    return ExperienceEntity(
      company: company,
      position: 'Engineer',
      location: 'Madrid',
      startDate: startDate,
      endDate: endDate,
      current: isCurrent,
      employmentType: 'full-time',
      description: description,
      longDescription: '',
      responsibilities: responsibilities,
      achievements: achievements,
      technologies: const [],
      companyLogo: '',
      url: 'https://${company.replaceAll(' ', '').toLowerCase()}.example.com',
      id: company,
    );
  }

  static ProjectEntity _project({
    required String title,
    required DateTime startDate,
    List<ProjectMarketEntity> markets = const [],
    String status = 'completed',
  }) {
    return ProjectEntity(
      title: title,
      description: 'Description of $title',
      longDescription: '',
      technologies: const ['Flutter'],
      category: 'mobile',
      status: status,
      startDate: startDate,
      endDate: null,
      image: '',
      features: const [],
      achievements: const [],
      teamSize: 3,
      role: 'Lead',
      markets: markets,
      id: title,
    );
  }
}
