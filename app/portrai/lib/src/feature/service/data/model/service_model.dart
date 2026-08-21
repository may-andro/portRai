import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel {
  ServiceModel({
    required this.title,
    required this.description,
    required this.image,
    required this.detail,
    required this.locale,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  final String title;
  final String description;
  final String image;
  final String detail;
  final String locale;

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}
