import 'package:json_annotation/json_annotation.dart';

part 'ai_rate_limit_app_config_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AiRateLimitAppConfigModel {
  const AiRateLimitAppConfigModel({
    this.maxRequestsPerMinute,
    this.maxRequestsPerDay,
  });

  factory AiRateLimitAppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AiRateLimitAppConfigModelFromJson(json);

  final int? maxRequestsPerMinute;
  final int? maxRequestsPerDay;

  Map<String, dynamic> toJson() => _$AiRateLimitAppConfigModelToJson(this);
}
