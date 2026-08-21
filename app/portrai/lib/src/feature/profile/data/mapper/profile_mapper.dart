import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/mapper/availability_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/education_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/language_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/location_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/published_at_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/resume_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/social_link_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/working_hours_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class ProfileMapper implements BiMapper<ProfileModel, ProfileEntity> {
  const ProfileMapper({
    required this.publishedAtMapper,
    required this.resumeMapper,
    required this.socialLinkMapper,
    required this.availabilityMapper,
    required this.workingHoursMapper,
    required this.locationMapper,
    required this.languageMapper,
    required this.educationMapper,
    required this.appLocale,
  });

  final PublishedAtMapper publishedAtMapper;
  final ResumeMapper resumeMapper;
  final SocialLinkMapper socialLinkMapper;
  final AvailabilityMapper availabilityMapper;
  final WorkingHoursMapper workingHoursMapper;
  final LocationMapper locationMapper;
  final LanguageMapper languageMapper;
  final EducationMapper educationMapper;
  final AppLocale appLocale;

  @override
  ProfileModel from(ProfileEntity entity) {
    return ProfileModel(
      fullName: entity.fullName,
      title: entity.title,
      subtitle: entity.subtitle,
      email: entity.email,
      phone: entity.phone,
      profileImage: entity.profileImage,
      coverImage: entity.coverImage,
      summary: entity.summary,
      detailedBio: entity.detailedBio,
      elevatorPitch: entity.elevatorPitch,
      uniqueValueProposition: entity.uniqueValueProposition,
      publishedAt: entity.publishedAt
          .map((e) => publishedAtMapper.from(e))
          .toList(),
      resume: resumeMapper.from(entity.resume),
      socialLinks: entity.socialLinks
          .map((e) => socialLinkMapper.from(e))
          .toList(),
      availability: availabilityMapper.from(entity.availability),
      workingHours: workingHoursMapper.from(entity.workingHours),
      currentRole: entity.currentRole,
      currentCompany: entity.currentCompany,
      yearsOfExperience: entity.yearsOfExperience,
      projectsDelivered: entity.projectsDelivered,
      location: locationMapper.from(entity.location),
      languages: entity.languages.map((e) => languageMapper.from(e)).toList(),
      educations: entity.educations
          .map((e) => educationMapper.from(e))
          .toList(),
      locale: appLocale.languageCode,
    );
  }

  @override
  ProfileEntity to(ProfileModel model) {
    return ProfileEntity(
      fullName: model.fullName,
      title: model.title,
      subtitle: model.subtitle,
      email: model.email,
      phone: model.phone,
      profileImage: model.profileImage,
      coverImage: model.coverImage,
      summary: model.summary,
      detailedBio: model.detailedBio,
      elevatorPitch: model.elevatorPitch,
      uniqueValueProposition: model.uniqueValueProposition,
      publishedAt: model.publishedAt
          .map((e) => publishedAtMapper.to(e))
          .toList(),
      resume: resumeMapper.to(model.resume),
      socialLinks: model.socialLinks
          .map((e) => socialLinkMapper.to(e))
          .toList(),
      availability: availabilityMapper.to(model.availability),
      workingHours: workingHoursMapper.to(model.workingHours),
      currentRole: model.currentRole,
      currentCompany: model.currentCompany,
      yearsOfExperience: model.yearsOfExperience,
      projectsDelivered: model.projectsDelivered,
      location: locationMapper.to(model.location),
      languages: model.languages.map((e) => languageMapper.to(e)).toList(),
      educations: model.educations.map((e) => educationMapper.to(e)).toList(),
    );
  }
}
