import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/profile/domain/entity/availability_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/education_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/language_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/location_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/published_at_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/resume_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/social_link_entity.dart';
import 'package:portrai/src/feature/profile/domain/entity/working_hours_entity.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.fullName,
    required this.title,
    required this.subtitle,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.coverImage,
    required this.summary,
    required this.detailedBio,
    required this.elevatorPitch,
    required this.uniqueValueProposition,
    required this.publishedAt,
    required this.resume,
    required this.socialLinks,
    required this.availability,
    required this.workingHours,
    required this.currentRole,
    required this.currentCompany,
    required this.yearsOfExperience,
    required this.projectsDelivered,
    required this.location,
    required this.languages,
    required this.educations,
  });

  final String fullName;
  final String title;
  final String subtitle;
  final String email;
  final String phone;
  final String profileImage;
  final String coverImage;
  final String summary;
  final String detailedBio;
  final String elevatorPitch;
  final String uniqueValueProposition;
  final List<PublishedAtEntity> publishedAt;
  final ResumeEntity resume;
  final List<SocialLinkEntity> socialLinks;
  final AvailabilityEntity availability;
  final WorkingHoursEntity workingHours;
  final String currentRole;
  final String currentCompany;
  final int yearsOfExperience;
  final int projectsDelivered;
  final LocationEntity location;
  final List<LanguageEntity> languages;
  final List<EducationEntity> educations;

  @override
  List<Object?> get props => [
    fullName,
    title,
    subtitle,
    email,
    phone,
    profileImage,
    coverImage,
    summary,
    detailedBio,
    elevatorPitch,
    uniqueValueProposition,
    publishedAt,
    resume,
    socialLinks,
    availability,
    workingHours,
    currentRole,
    currentCompany,
    yearsOfExperience,
    projectsDelivered,
    location,
    languages,
    educations,
  ];
}
