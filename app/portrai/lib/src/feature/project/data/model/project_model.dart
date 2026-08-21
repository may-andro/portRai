import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.longDescription,
    required this.image,
    required this.technologies,
    required this.category,
    required this.status,
    required this.startDate,
    required this.features,
    required this.achievements,
    required this.teamSize,
    required this.role,
    required this.locale,
    this.endDate,
    this.appStore,
    this.playStore,
    this.website,
    this.github,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  final String id;
  final String title;
  final String description;
  final String longDescription;
  final String image;
  final List<String> technologies;
  final String category;
  final String status;
  final List<String> features;
  final List<String> achievements;
  final int teamSize;
  final String role;
  final String startDate;
  final String? endDate;
  final String? appStore;
  final String? playStore;
  final String? website;
  final String? github;
  final String locale;

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}
