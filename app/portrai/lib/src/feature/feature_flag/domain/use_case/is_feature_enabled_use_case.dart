import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';
import 'package:portrai/src/feature/feature_flag/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class IsFeatureEnabledFailure extends BasicFailure {
  const IsFeatureEnabledFailure({super.cause});
}

@Localizable('errorFeatureFlagNotFound')
class FeatureFlagNotFoundFailure extends IsFeatureEnabledFailure {
  const FeatureFlagNotFoundFailure({super.cause});
}

@Localizable('errorFeatureFlagUnknown')
class FeatureFlagUnknownFailure extends IsFeatureEnabledFailure {
  const FeatureFlagUnknownFailure({super.cause});
}

@register
class IsFeatureEnabledUseCase
    extends
        BaseUseCase<bool, AppFeatureFlagDefinition, IsFeatureEnabledFailure> {
  IsFeatureEnabledUseCase(this._repository);

  final AppFeatureFlagRepository _repository;

  @protected
  @override
  Future<Either<IsFeatureEnabledFailure, bool>> execute(
    AppFeatureFlagDefinition flag,
  ) async {
    final isEnabled = _repository.isFeatureEnabled(flag);
    return Right(isEnabled);
  }

  @protected
  @override
  IsFeatureEnabledFailure mapErrorToFailure(Object e, StackTrace st) {
    return FeatureFlagUnknownFailure(cause: e);
  }
}
