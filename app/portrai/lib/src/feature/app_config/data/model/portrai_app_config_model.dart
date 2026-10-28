import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/app_config/data/model/ai_image_app_config_model.dart';
import 'package:portrai/src/feature/app_config/data/model/ai_rate_limit_app_config_model.dart';

part 'portrai_app_config_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PortraiAppConfigModel {
  const PortraiAppConfigModel({
    required this.minimumRequiredAppVersion,
    this.aiImage,
    this.aiAssistantModel,
    this.aiRateLimit,
    this.termsUrl,
    this.privacyPolicyUrl,
  });

  factory PortraiAppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$PortraiAppConfigModelFromJson(json);

  final String minimumRequiredAppVersion;
  final AiImageAppConfigModel? aiImage;
  final String? aiAssistantModel;
  final AiRateLimitAppConfigModel? aiRateLimit;
  final String? termsUrl;
  final String? privacyPolicyUrl;

  Map<String, dynamic> toJson() => _$PortraiAppConfigModelToJson(this);
}
