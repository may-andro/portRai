import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant_availability.dart';
import 'package:use_case/use_case.dart';

@register
class GetLocalAssistantAvailabilityUseCase
    extends
        BaseNoParamUseCase<
          AssistantAvailabilityEntity,
          IsFeatureEnabledFailure
        > {
  GetLocalAssistantAvailabilityUseCase(this._access, this._availability);

  final IsFeatureEnabledUseCase _access;
  final LocalAssistantAvailability _availability;

  @protected
  @override
  Future<Either<IsFeatureEnabledFailure, AssistantAvailabilityEntity>>
  execute() async {
    final result = await _access(LocalAssistantFeatureFlags.aiAssistant);
    if (result.isLeft) return Left(result.left);
    return Right(
      AssistantAvailabilityEntity(
        isFeatureEnabled: result.right,
        isSupported: _availability.isSupported,
      ),
    );
  }

  @protected
  @override
  IsFeatureEnabledFailure mapErrorToFailure(Object e, StackTrace st) =>
      FeatureFlagUnknownFailure(cause: e);
}
