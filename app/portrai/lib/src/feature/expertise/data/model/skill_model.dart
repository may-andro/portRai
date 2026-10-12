import 'package:json_annotation/json_annotation.dart';

part 'skill_model.g.dart';

@JsonSerializable()
class SkillModel {
  SkillModel({required this.name, this.level, this.years, this.lastUsed});

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);

  final String name;
  final String? level;
  final int? years;
  final int? lastUsed;

  Map<String, dynamic> toJson() => _$SkillModelToJson(this);
}
