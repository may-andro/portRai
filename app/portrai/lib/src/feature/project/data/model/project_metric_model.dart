import 'package:json_annotation/json_annotation.dart';

part 'project_metric_model.g.dart';

@JsonSerializable()
class ProjectMetricModel {
  ProjectMetricModel({required this.label, required this.value});

  factory ProjectMetricModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectMetricModelFromJson(json);

  final String label;
  final String value;

  Map<String, dynamic> toJson() => _$ProjectMetricModelToJson(this);
}
