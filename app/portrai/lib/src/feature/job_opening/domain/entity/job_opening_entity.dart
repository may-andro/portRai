import 'package:equatable/equatable.dart';

/// A job opening the weekly function found and scored for the signed-in user.
class JobOpeningEntity extends Equatable {
  const JobOpeningEntity({
    required this.id,
    required this.sourceName,
    required this.title,
    required this.company,
    required this.url,
    required this.location,
    required this.tags,
    required this.jobTypes,
    required this.description,
    required this.score,
    required this.matchedSkills,
    required this.missingSkills,
    required this.reasons,
    required this.publishedAt,
    required this.fetchedAt,
  });

  final String id;

  /// The job board the opening came from, shown with the job as its
  /// attribution.
  final String sourceName;
  final String title;
  final String company;

  /// The job page on the source site. Applying and attribution link here.
  final Uri url;
  final String? location;
  final List<String> tags;
  final List<String> jobTypes;
  final String description;

  /// How well the job fits the portfolio, from 0 to 100.
  final int score;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> reasons;
  final DateTime publishedAt;
  final DateTime fetchedAt;

  @override
  List<Object?> get props => [
    id,
    sourceName,
    title,
    company,
    url,
    location,
    tags,
    jobTypes,
    description,
    score,
    matchedSkills,
    missingSkills,
    reasons,
    publishedAt,
    fetchedAt,
  ];
}
