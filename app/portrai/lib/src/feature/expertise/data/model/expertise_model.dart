import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/expertise/data/model/skill_model.dart';

part 'expertise_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExpertiseModel {
  ExpertiseModel({
    required this.image,
    required this.title,
    required this.skills,
    required this.locale,
    this.summary,
  });

  factory ExpertiseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpertiseModelFromJson(json);

  final String image;
  final String title;
  final List<SkillModel> skills;
  final String locale;
  final String? summary;

  Map<String, dynamic> toJson() => _$ExpertiseModelToJson(this);
}
