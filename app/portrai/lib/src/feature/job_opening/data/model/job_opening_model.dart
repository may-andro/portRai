import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/job_opening/data/model/firestore_date_time_converter.dart';

part 'job_opening_model.g.dart';

/// A `users/{uid}/job_openings/{id}` document, written by the weekly Cloud
/// Function. The ID is the document ID, added when the document is read.
@JsonSerializable(explicitToJson: true)
@FirestoreDateTimeConverter()
class JobOpeningModel {
  JobOpeningModel({
    required this.id,
    required this.sourceName,
    required this.title,
    required this.company,
    required this.url,
    required this.description,
    required this.score,
    required this.publishedAt,
    required this.fetchedAt,
    this.location,
    this.tags = const [],
    this.jobTypes = const [],
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.reasons = const [],
  });

  factory JobOpeningModel.fromJson(Map<String, dynamic> json) =>
      _$JobOpeningModelFromJson(json);

  final String id;
  final String sourceName;
  final String title;
  final String company;
  final String url;
  final String? location;
  final List<String> tags;
  final List<String> jobTypes;
  final String description;
  final num score;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> reasons;
  final DateTime publishedAt;
  final DateTime fetchedAt;

  Map<String, dynamic> toJson() => _$JobOpeningModelToJson(this);
}
