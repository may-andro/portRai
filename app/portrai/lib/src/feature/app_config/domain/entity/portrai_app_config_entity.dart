import 'package:core/core.dart';
import 'package:portrai/src/feature/app_config/domain/entity/ai_image_app_config.dart';
import 'package:portrai/src/feature/app_config/domain/entity/ai_rate_limit_app_config.dart';

class PortraiAppConfigEntity extends AppConfig {
  const PortraiAppConfigEntity({
    required this.minimumRequiredAppVersion,
    this.aiImage = const AiImageAppConfig(),
    this.aiAssistantModel,
    this.aiRateLimit = const AiRateLimitAppConfig(),
  });

  final String minimumRequiredAppVersion;
  final AiImageAppConfig aiImage;

  /// Gemini model id for the remote assistant; null means the built-in default.
  final String? aiAssistantModel;

  final AiRateLimitAppConfig aiRateLimit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortraiAppConfigEntity &&
          runtimeType == other.runtimeType &&
          minimumRequiredAppVersion == other.minimumRequiredAppVersion &&
          aiImage == other.aiImage &&
          aiAssistantModel == other.aiAssistantModel &&
          aiRateLimit == other.aiRateLimit;

  @override
  int get hashCode => Object.hash(
    minimumRequiredAppVersion,
    aiImage,
    aiAssistantModel,
    aiRateLimit,
  );

  @override
  String toString() =>
      'PortraiAppConfigEntity(minimumRequiredAppVersion: '
      '$minimumRequiredAppVersion, aiImage: $aiImage, '
      'aiAssistantModel: $aiAssistantModel, aiRateLimit: $aiRateLimit)';
}
