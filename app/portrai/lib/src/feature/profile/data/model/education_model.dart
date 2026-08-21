import 'package:json_annotation/json_annotation.dart';

part 'education_model.g.dart';

@JsonSerializable()
class EducationModel {
  const EducationModel({
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.url,
    required this.location,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) =>
      _$EducationModelFromJson(json);

  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String endDate;
  final String image;
  final String url;
  final String location;

  Map<String, dynamic> toJson() => _$EducationModelToJson(this);
}
