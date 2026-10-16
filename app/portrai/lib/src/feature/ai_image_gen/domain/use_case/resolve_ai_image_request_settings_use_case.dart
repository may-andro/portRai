import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/use_case/get_ai_image_settings_use_case.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:use_case/use_case.dart';

/// A stored (dev menu) selection wins, then the app config, then defaults.
@register
class ResolveAiImageRequestSettingsUseCase
    extends BaseNoParamUseCase<AiImageRequestSettings, NoFailure> {
  ResolveAiImageRequestSettingsUseCase(
    this._getSettingsUseCase,
    this._appConfig,
  );

  final GetAiImageSettingsUseCase _getSettingsUseCase;
  final PortraiAppConfigEntity _appConfig;

  @protected
  @override
  FutureOr<Either<NoFailure, AiImageRequestSettings>> execute() async {
    final settings = (await _getSettingsUseCase()).right;
    final config = _appConfig.aiImage;
    return Right(
      AiImageRequestSettings(
        prompt:
            settings?.style.prompt ??
            AiImageStyle.values.asNameMap()[config.style]?.prompt ??
            AiImageStyle.avatar.prompt,
        model:
            settings?.model.id ??
            _nonBlank(config.model) ??
            AiImageModelType.geminiFlashImage.id,
      ),
    );
  }

  String? _nonBlank(String? value) =>
      value == null || value.trim().isEmpty ? null : value;

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
