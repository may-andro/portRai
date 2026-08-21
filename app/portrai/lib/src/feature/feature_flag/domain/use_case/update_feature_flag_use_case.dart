import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';
import 'package:portrai/src/feature/feature_flag/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class UpdateFeatureFlagFailure extends BasicFailure {
  const UpdateFeatureFlagFailure({super.cause});
}

@Localizable('errorFeatureFlagUpdateFailed')
class FeatureFlagUpdateFailedFailure extends UpdateFeatureFlagFailure {
  const FeatureFlagUpdateFailedFailure({super.cause});
}

@Localizable('errorFeatureFlagUpdateUnknown')
class FeatureFlagUpdateUnknownFailure extends UpdateFeatureFlagFailure {
  const FeatureFlagUpdateUnknownFailure({super.cause});
}

@register
class UpdateFeatureFlagUseCase
    extends BaseUseCase<void, AppFeatureFlagEntity, UpdateFeatureFlagFailure> {
  UpdateFeatureFlagUseCase(this._repository);

  final AppFeatureFlagRepository _repository;

  @protected
  @override
  Future<Either<UpdateFeatureFlagFailure, void>> execute(
    AppFeatureFlagEntity flag,
  ) async {
    await _repository.updateFeatureFlag(flag);
    return const Right(null);
  }

  @protected
  @override
  UpdateFeatureFlagFailure mapErrorToFailure(Object e, StackTrace st) {
    return FeatureFlagUpdateUnknownFailure(cause: e);
  }
}
