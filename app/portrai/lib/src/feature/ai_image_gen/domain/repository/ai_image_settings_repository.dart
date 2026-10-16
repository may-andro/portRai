import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

abstract class AiImageSettingsRepository {
  /// The stored selection, or null when none has been made.
  Future<AiImageSettings?> getSettings();

  Future<void> setSettings(AiImageSettings settings);
}
