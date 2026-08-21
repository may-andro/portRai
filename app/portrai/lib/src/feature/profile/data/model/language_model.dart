import 'package:json_annotation/json_annotation.dart';

part 'language_model.g.dart';

@JsonSerializable()
class LanguageModel {
  LanguageModel({required this.language, required this.proficiency});

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  final String language;
  final String proficiency;

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);
}
