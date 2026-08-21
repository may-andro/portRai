import 'package:json_annotation/json_annotation.dart';

part 'coordinates_model.g.dart';

@JsonSerializable()
class CoordinatesModel {
  CoordinatesModel({required this.latitude, required this.longitude});

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesModelFromJson(json);

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$CoordinatesModelToJson(this);
}
