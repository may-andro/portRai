import 'package:core/core.dart';
import 'package:portrai/src/feature/app_config/domain/entity/ai_image_app_config.dart';

class PortraiAppConfigEntity extends AppConfig {
  const PortraiAppConfigEntity({
    required this.minimumRequiredAppVersion,
    this.aiImage = const AiImageAppConfig(),
  });

  final String minimumRequiredAppVersion;
  final AiImageAppConfig aiImage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortraiAppConfigEntity &&
          runtimeType == other.runtimeType &&
          minimumRequiredAppVersion == other.minimumRequiredAppVersion &&
          aiImage == other.aiImage;

  @override
  int get hashCode => Object.hash(minimumRequiredAppVersion, aiImage);

  @override
  String toString() =>
      'PortraiAppConfigEntity(minimumRequiredAppVersion: '
      '$minimumRequiredAppVersion, aiImage: $aiImage)';
}
