import 'package:json_annotation/json_annotation.dart';

part 'working_hours_model.g.dart';

@JsonSerializable()
class WorkingHoursModel {
  WorkingHoursModel({
    required this.timezone,
    required this.preferredHours,
    required this.weekdays,
    required this.weekends,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursModelFromJson(json);

  final String timezone;
  final String preferredHours;
  final bool weekdays;
  final String weekends;

  Map<String, dynamic> toJson() => _$WorkingHoursModelToJson(this);
}
