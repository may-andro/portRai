import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/project/data/model/project_market_model.dart';
import 'package:portrai/src/feature/project/data/model/project_metric_model.dart';

part 'project_model.g.dart';

@JsonSerializable(explicitToJson: true)
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
    this.experienceId,

    this.markets = const [],
    this.metrics = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  final String id;
  final String? experienceId;
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
  final List<ProjectMarketModel> markets;
  final List<ProjectMetricModel> metrics;
  final String locale;

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}
