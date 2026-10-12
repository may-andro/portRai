import 'package:equatable/equatable.dart';

class TestimonialEntity extends Equatable {
  const TestimonialEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.company,
    required this.testimonial,
    required this.date,
    required this.profileImage,
    required this.companyLogo,
    required this.linkedinProfile,
    required this.projectContext,
    this.experienceId,
  });

  final String id;
  final String name;
  final String position;
  final String company;
  final String testimonial;
  final String date;
  final String profileImage;
  final String companyLogo;
  final String linkedinProfile;
  final String projectContext;

  /// The experience (employer) the author worked with the portfolio owner on.
  final String? experienceId;

  @override
  List<Object?> get props => [
    id,
    name,
    position,
    company,
    testimonial,
    date,
    profileImage,
    companyLogo,
    linkedinProfile,
    projectContext,
    experienceId,
  ];
}
