import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

ProfileEntity createProfileEntity({List<PublishedAtEntity>? publishedAt}) {
  return ProfileEntity(
    fullName: 'Mayank Rai',
    title: 'Senior Flutter & Android Developer',
    subtitle: 'Mobile Architecture Specialist',
    email: 'mayank271993@gmail.com',
    phone: '+34-604467532',
    profileImage: 'https://example.com/profile.png',
    coverImage: 'https://example.com/cover.png',
    summary: 'Builds products that scale.',
    detailedBio: 'Builds products that scale with clean architecture.',
    elevatorPitch: 'I craft mobile apps that feel great and scale well.',
    uniqueValueProposition: 'Engineering elegant, scalable mobile solutions',
    publishedAt:
        publishedAt ??
        const [
          PublishedAtEntity(
            name: 'Play Store',
            url: 'https://example.com/play',
            image: 'https://example.com/play.png',
          ),
          PublishedAtEntity(
            name: 'App Store',
            url: 'https://example.com/app-store',
            image: 'https://example.com/app-store.png',
          ),
        ],
    resume: const ResumeEntity(
      url: 'https://example.com/resume.pdf',
      lastUpdated: '2025-10-15',
      image: 'https://example.com/resume.png',
    ),
    socialLinks: const [
      SocialLinkEntity(
        name: 'Github',
        url: 'https://github.com/example',
        image: 'https://example.com/github.png',
      ),
      SocialLinkEntity(
        name: 'Portfolio',
        url: 'https://example.com/portfolio',
        image: 'https://example.com/portfolio.png',
      ),
    ],
    availability: const AvailabilityEntity(
      status: 'Available for consulting',
      workType: 'Remote',
      openToRelocate: false,
      preferredProjectDuration: '3-12 months',
      hourlyRate: '€75/hour',
      availability: 'Part-time',
    ),
    workingHours: const WorkingHoursEntity(
      timezone: 'Europe/Madrid',
      preferredHours: '09:00 - 18:00',
      weekdays: true,
      weekends: 'Limited availability',
    ),
    currentRole: 'Tech Lead',
    currentCompany: 'PortRai',
    yearsOfExperience: 10,
    projectsDelivered: 24,
    location: const LocationEntity(
      city: 'Alicante',
      state: 'Valencian Community',
      country: 'Spain',
      timezone: 'Madrid, Spain (GMT+1)',
      coordinates: CoordinatesEntity(latitude: 38.3452, longitude: -0.481),
    ),
    languages: const [
      LanguageEntity(language: 'English', proficiency: 'Fluent'),
      LanguageEntity(language: 'Spanish', proficiency: 'Intermediate'),
    ],
    educations: const [
      EducationEntity(
        institution: 'Army Institute of Technology',
        degree: 'Bachelor in Engineering',
        field: 'Electronics & Telecommunication',
        startDate: '2011-07-01',
        endDate: '2015-06-30',
        image: 'https://example.com/education.png',
        url: 'https://example.com/education',
        location: 'Pune, India',
      ),
    ],
  );
}

ProfileModel createProfileModel({String locale = 'en'}) {
  return ProfileModel(
    fullName: 'Mayank Rai',
    title: 'Senior Flutter & Android Developer',
    subtitle: 'Mobile Architecture Specialist',
    email: 'mayank271993@gmail.com',
    phone: '+34-604467532',
    profileImage: 'https://example.com/profile.png',
    coverImage: 'https://example.com/cover.png',
    summary: 'Builds products that scale.',
    detailedBio: 'Builds products that scale with clean architecture.',
    elevatorPitch: 'I craft mobile apps that feel great and scale well.',
    uniqueValueProposition: 'Engineering elegant, scalable mobile solutions',
    publishedAt: [
      PublishedAtModel(
        name: 'Play Store',
        url: 'https://example.com/play',
        image: 'https://example.com/play.png',
      ),
      PublishedAtModel(
        name: 'App Store',
        url: 'https://example.com/app-store',
        image: 'https://example.com/app-store.png',
      ),
    ],
    resume: ResumeModel(
      url: 'https://example.com/resume.pdf',
      lastUpdated: '2025-10-15',
      image: 'https://example.com/resume.png',
    ),
    socialLinks: [
      SocialLinkModel(
        name: 'Github',
        url: 'https://github.com/example',
        image: 'https://example.com/github.png',
      ),
      SocialLinkModel(
        name: 'Portfolio',
        url: 'https://example.com/portfolio',
        image: 'https://example.com/portfolio.png',
      ),
    ],
    availability: AvailabilityModel(
      status: 'Available for consulting',
      workType: 'Remote',
      openToRelocate: false,
      preferredProjectDuration: '3-12 months',
      hourlyRate: '€75/hour',
      availability: 'Part-time',
    ),
    workingHours: WorkingHoursModel(
      timezone: 'Europe/Madrid',
      preferredHours: '09:00 - 18:00',
      weekdays: true,
      weekends: 'Limited availability',
    ),
    currentRole: 'Tech Lead',
    currentCompany: 'PortRai',
    yearsOfExperience: 10,
    projectsDelivered: 24,
    location: LocationModel(
      city: 'Alicante',
      state: 'Valencian Community',
      country: 'Spain',
      timezone: 'Madrid, Spain (GMT+1)',
      coordinates: CoordinatesModel(latitude: 38.3452, longitude: -0.481),
    ),
    languages: [
      LanguageModel(language: 'English', proficiency: 'Fluent'),
      LanguageModel(language: 'Spanish', proficiency: 'Intermediate'),
    ],
    educations: const [
      EducationModel(
        institution: 'Army Institute of Technology',
        degree: 'Bachelor in Engineering',
        field: 'Electronics & Telecommunication',
        startDate: '2011-07-01',
        endDate: '2015-06-30',
        image: 'https://example.com/education.png',
        url: 'https://example.com/education',
        location: 'Pune, India',
      ),
    ],
    locale: locale,
  );
}

Map<String, dynamic> createProfileJson({String locale = 'en'}) {
  return createProfileModel(locale: locale).toJson();
}

Map<String, dynamic> createProfileAssetJson({String locale = 'en'}) {
  return {
    locale: {
      'profile': createProfileJson(locale: locale),
      'updatedAt': '2025-10-15T10:00:00Z',
    },
  };
}
