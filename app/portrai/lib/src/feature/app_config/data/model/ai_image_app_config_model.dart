import 'package:json_annotation/json_annotation.dart';

part 'ai_image_app_config_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AiImageAppConfigModel {
  const AiImageAppConfigModel({this.model, this.style});

  factory AiImageAppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AiImageAppConfigModelFromJson(json);

  final String? model;
  final String? style;

  Map<String, dynamic> toJson() => _$AiImageAppConfigModelToJson(this);
}
