import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

class ExperienceEntity extends Equatable {
  const ExperienceEntity({
    required this.company,
    required this.position,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.current,
    required this.employmentType,
    required this.description,
    required this.longDescription,
    required this.responsibilities,
    required this.achievements,
    required this.technologies,
    required this.companyLogo,
    required this.url,
    required this.id,
  });

  final String company;
  final String position;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String employmentType;
  final String description;
  final String longDescription;
  final List<String> responsibilities;
  final List<String> achievements;
  final List<String> technologies;
  final String companyLogo;
  final String? url;
  final String id;

  @override
  List<Object?> get props => [
    company,
    position,
    location,
    startDate,
    endDate,
    current,
    employmentType,
    description,
    longDescription,
    responsibilities,
    achievements,
    technologies,
    companyLogo,
    url,
    id,
  ];

  String get formattedExperienceDateRange {
    final start = DateFormat.yMMM().format(startDate).capitalize;
    final end = endDate != null
        ? DateFormat.yMMM().format(endDate!).capitalize
        : 'Present';
    return '$start - $end';
  }
}
