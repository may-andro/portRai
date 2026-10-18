import 'package:json_annotation/json_annotation.dart';

part 'language_model.g.dart';

@JsonSerializable()
class LanguageModel {
  LanguageModel({required this.language, required this.proficiency, this.code});

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  final String language;
  final String proficiency;

  /// ISO 639-1 code, independent of the portfolio language.
  final String? code;

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);
}
