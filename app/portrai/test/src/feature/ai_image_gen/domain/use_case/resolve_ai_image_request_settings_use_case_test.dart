import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

import '../../../../../mock/feature/ai_image_gen/domain/use_case/mock_get_ai_image_settings_use_case.dart';

void main() {
  group('ResolveAiImageRequestSettingsUseCase', () {
    late MockGetAiImageSettingsUseCase getSettingsUseCase;

    setUp(() {
      getSettingsUseCase = MockGetAiImageSettingsUseCase()..stubCall(null);
    });

    ResolveAiImageRequestSettingsUseCase buildUseCase({
      AiImageAppConfig aiImage = const AiImageAppConfig(),
    }) => ResolveAiImageRequestSettingsUseCase(
      getSettingsUseCase,
      PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.0.0',
        aiImage: aiImage,
      ),
    );

    test(
      'should prefer the stored selection when it exists alongside the app config',
      () async {
        getSettingsUseCase.stubCall(
          const AiImageSettings(
            style: AiImageStyle.naruto,
            model: AiImageModelType.geminiProImage,
          ),
        );

        final result = await buildUseCase(
          aiImage: const AiImageAppConfig(
            model: 'remote-model',
            style: 'manga',
          ),
        )();

        expect(
          result.right,
          AiImageRequestSettings(
            prompt: AiImageStyle.naruto.prompt,
            model: AiImageModelType.geminiProImage.id,
          ),
        );
      },
    );

    test(
      'should use the app config model and prompt when no selection is stored',
      () async {
        final result = await buildUseCase(
          aiImage: const AiImageAppConfig(
            model: 'remote-model',
            style: 'manga',
          ),
        )();

        expect(
          result.right,
          AiImageRequestSettings(
            prompt: AiImageStyle.manga.prompt,
            model: 'remote-model',
          ),
        );
      },
    );

    test(
      'should use the defaults when no selection is stored and the config is empty',
      () async {
        final result = await buildUseCase()();

        expect(
          result.right,
          AiImageRequestSettings(
            prompt: AiImageStyle.avatar.prompt,
            model: AiImageModelType.geminiFlashImage.id,
          ),
        );
      },
    );
  });
}
