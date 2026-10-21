import 'package:json_annotation/json_annotation.dart';

part 'job_search_model.g.dart';

/// The `jobSearch` map on a `users/{uid}` document.
@JsonSerializable()
class JobSearchModel {
  JobSearchModel({this.enabled = false});

  factory JobSearchModel.fromJson(Map<String, dynamic> json) =>
      _$JobSearchModelFromJson(json);

  final bool enabled;

  Map<String, dynamic> toJson() => _$JobSearchModelToJson(this);
}
