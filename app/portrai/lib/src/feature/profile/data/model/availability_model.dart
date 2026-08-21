import 'package:json_annotation/json_annotation.dart';

part 'availability_model.g.dart';

@JsonSerializable()
class AvailabilityModel {
  AvailabilityModel({
    required this.status,
    required this.workType,
    required this.openToRelocate,
    required this.preferredProjectDuration,
    required this.hourlyRate,
    required this.availability,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityModelFromJson(json);

  final String status;
  final String workType;
  final bool openToRelocate;
  final String preferredProjectDuration;
  final String hourlyRate;
  final String availability;

  Map<String, dynamic> toJson() => _$AvailabilityModelToJson(this);
}
