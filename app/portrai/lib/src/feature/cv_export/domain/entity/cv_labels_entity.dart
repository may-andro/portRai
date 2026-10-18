import 'package:equatable/equatable.dart';

/// Localized texts and formatting locale used while rendering the CV.
class CvLabelsEntity extends Equatable {
  const CvLabelsEntity({
    required this.localeCode,
    required this.presentLabel,
    required this.summaryHeading,
    required this.experienceHeading,
    required this.projectsHeading,
    required this.skillsHeading,
    required this.educationHeading,
    required this.contactHeading,
    required this.moreExperienceLabel,
  });

  final String localeCode;
  final String presentLabel;
  final String summaryHeading;
  final String experienceHeading;
  final String projectsHeading;
  final String skillsHeading;
  final String educationHeading;
  final String contactHeading;
  final String moreExperienceLabel;

  @override
  List<Object?> get props => [
    localeCode,
    presentLabel,
    summaryHeading,
    experienceHeading,
    projectsHeading,
    skillsHeading,
    educationHeading,
    contactHeading,
    moreExperienceLabel,
  ];
}
