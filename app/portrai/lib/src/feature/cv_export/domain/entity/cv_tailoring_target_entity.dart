import 'package:equatable/equatable.dart';

/// The job a CV is tailored for.
class CvTailoringTargetEntity extends Equatable {
  const CvTailoringTargetEntity({
    required this.title,
    required this.company,
    required this.description,
    this.skills = const [],
  });

  final String title;
  final String company;
  final String description;

  /// Skills the job asks for.
  final List<String> skills;

  @override
  List<Object?> get props => [title, company, description, skills];
}
