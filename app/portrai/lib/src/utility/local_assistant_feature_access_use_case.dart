import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

/// App-level composition: a remote rollout blocks local access even when the
/// remote provider is unsupported or has not received consent.
@register
class LocalAssistantFeatureAccessUseCase extends IsFeatureEnabledUseCase {
  LocalAssistantFeatureAccessUseCase(this._repository) : super(_repository);

  final AppFeatureFlagRepository _repository;

  @override
  Future<Either<IsFeatureEnabledFailure, bool>> execute(
    AppFeatureFlagDefinition flag,
  ) async {
    if (_repository.isFeatureEnabled(
      RemoteAssistantFeatureFlags.remoteAssistant,
    )) {
      return const Right(false);
    }
    return await super.execute(flag);
  }
}
