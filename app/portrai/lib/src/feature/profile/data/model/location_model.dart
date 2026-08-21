import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/profile/data/model/coordinates_model.dart';

part 'location_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationModel {
  LocationModel({
    required this.city,
    required this.state,
    required this.country,
    required this.timezone,
    required this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  final String city;
  final String state;
  final String country;
  final String timezone;
  final CoordinatesModel coordinates;

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
