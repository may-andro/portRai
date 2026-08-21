import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/profile/data/model/availability_model.dart';
import 'package:portrai/src/feature/profile/data/model/education_model.dart';
import 'package:portrai/src/feature/profile/data/model/language_model.dart';
import 'package:portrai/src/feature/profile/data/model/location_model.dart';
import 'package:portrai/src/feature/profile/data/model/published_at_model.dart';
import 'package:portrai/src/feature/profile/data/model/resume_model.dart';
import 'package:portrai/src/feature/profile/data/model/social_link_model.dart';
import 'package:portrai/src/feature/profile/data/model/working_hours_model.dart';

part 'profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProfileModel {
  ProfileModel({
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
    required this.locale,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

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
  final List<PublishedAtModel> publishedAt;
  final ResumeModel resume;
  final List<SocialLinkModel> socialLinks;
  final AvailabilityModel availability;
  final WorkingHoursModel workingHours;
  final String currentRole;
  final String currentCompany;
  final int yearsOfExperience;
  final int projectsDelivered;
  final LocationModel location;
  final List<LanguageModel> languages;
  final List<EducationModel> educations;
  final String locale;

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
