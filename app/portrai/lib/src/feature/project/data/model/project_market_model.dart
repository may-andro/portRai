import 'package:json_annotation/json_annotation.dart';

part 'project_market_model.g.dart';

@JsonSerializable()
class ProjectMarketModel {
  ProjectMarketModel({
    required this.country,
    required this.latitude,
    required this.longitude,
    this.appStore,
    this.playStore,
    this.website,
  });

  factory ProjectMarketModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectMarketModelFromJson(json);

  final String country;
  final double latitude;
  final double longitude;
  final String? appStore;
  final String? playStore;
  final String? website;

  Map<String, dynamic> toJson() => _$ProjectMarketModelToJson(this);
}
