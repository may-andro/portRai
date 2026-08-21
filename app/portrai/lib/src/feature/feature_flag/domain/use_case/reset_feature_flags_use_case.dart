import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class ResetFeatureFlagsFailure extends BasicFailure {
  const ResetFeatureFlagsFailure({super.cause});
}

@Localizable('errorFeatureFlagsResetFailed')
class FeatureFlagsResetFailure extends ResetFeatureFlagsFailure {
  const FeatureFlagsResetFailure({super.cause});
}

@register
class ResetFeatureFlagsUseCase
    extends BaseNoParamUseCase<void, ResetFeatureFlagsFailure> {
  ResetFeatureFlagsUseCase(this._repository);

  final AppFeatureFlagRepository _repository;

  @protected
  @override
  Future<Either<ResetFeatureFlagsFailure, void>> execute() async {
    await _repository.reset();
    return const Right(null);
  }

  @protected
  @override
  ResetFeatureFlagsFailure mapErrorToFailure(Object e, StackTrace st) {
    return FeatureFlagsResetFailure(cause: e);
  }
}
