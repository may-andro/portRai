import 'package:json_annotation/json_annotation.dart';

part 'expertise_model.g.dart';

@JsonSerializable()
class ExpertiseModel {
  ExpertiseModel({
    required this.image,
    required this.title,
    required this.skills,
    required this.locale,
  });

  factory ExpertiseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpertiseModelFromJson(json);

  final String image;
  final String title;
  final List<String> skills;
  final String locale;

  Map<String, dynamic> toJson() => _$ExpertiseModelToJson(this);
}
