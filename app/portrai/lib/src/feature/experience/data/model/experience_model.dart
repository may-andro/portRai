import 'package:json_annotation/json_annotation.dart';

part 'experience_model.g.dart';

@JsonSerializable()
class ExperienceModel {
  ExperienceModel({
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
    required this.locale,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) =>
      _$ExperienceModelFromJson(json);

  final String company;
  final String position;
  final String location;
  final String startDate;
  final String? endDate;
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
  final String locale;

  Map<String, dynamic> toJson() => _$ExperienceModelToJson(this);
}
