import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

/// Whether a CV can be tailored for a job: the flag is on and the platform
/// supports cloud AI requests.
@register
class IsCvTailoringAvailableUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  IsCvTailoringAvailableUseCase(
    this._isFeatureEnabledUseCase,
    this._isRemoteAssistantSupportedUseCase,
  );

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final IsRemoteAssistantSupportedUseCase _isRemoteAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<NoFailure, bool>> execute() async {
    final isFeatureEnabledEither = await _isFeatureEnabledUseCase(
      CvExportFeatureFlags.tailoredCv,
    );
    if (isFeatureEnabledEither.isLeft || !isFeatureEnabledEither.right) {
      return const Right(false);
    }
    final isSupportedEither = await _isRemoteAssistantSupportedUseCase();
    return Right(isSupportedEither.isRight && isSupportedEither.right);
  }

  @protected
  @override
  NoFailure mapErrorToFailure(Object error, StackTrace stackTrace) =>
      NoFailure();
}
