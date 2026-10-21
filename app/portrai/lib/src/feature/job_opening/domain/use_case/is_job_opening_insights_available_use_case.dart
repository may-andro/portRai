import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/job_opening/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

/// Whether insights can be generated for a job opening: both its flag and the
/// remote assistant are on, and the platform supports the assistant.
@register
class IsJobOpeningInsightsAvailableUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  IsJobOpeningInsightsAvailableUseCase(
    this._isFeatureEnabledUseCase,
    this._isRemoteAssistantSupportedUseCase,
  );

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final IsRemoteAssistantSupportedUseCase _isRemoteAssistantSupportedUseCase;

  @protected
  @override
  FutureOr<Either<NoFailure, bool>> execute() async {
    for (final flag in [
      JobOpeningFeatureFlags.insights,
      RemoteAssistantFeatureFlags.remoteAssistant,
    ]) {
      final isFeatureEnabledEither = await _isFeatureEnabledUseCase(flag);
      if (isFeatureEnabledEither.isLeft || !isFeatureEnabledEither.right) {
        return const Right(false);
      }
    }
    final isSupportedEither = await _isRemoteAssistantSupportedUseCase();
    return Right(isSupportedEither.isRight && isSupportedEither.right);
  }

  @protected
  @override
  NoFailure mapErrorToFailure(Object error, StackTrace stackTrace) =>
      NoFailure();
}
