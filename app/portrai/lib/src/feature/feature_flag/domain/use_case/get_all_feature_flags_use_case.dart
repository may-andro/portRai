import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:use_case/use_case.dart';

sealed class GetAllFeatureFlagsFailure extends BasicFailure {
  const GetAllFeatureFlagsFailure({super.cause});
}

@Localizable('errorFeatureFlagsNotFound')
class FeatureFlagsNotFoundFailure extends GetAllFeatureFlagsFailure {
  const FeatureFlagsNotFoundFailure({super.cause});
}

@Localizable('errorFeatureFlagsUnknown')
class FeatureFlagsUnknownFailure extends GetAllFeatureFlagsFailure {
  const FeatureFlagsUnknownFailure({super.cause});
}

@register
class GetAllFeatureFlagsUseCase
    extends
        BaseNoParamUseCase<
          List<AppFeatureFlagEntity>,
          GetAllFeatureFlagsFailure
        > {
  GetAllFeatureFlagsUseCase(this._repository, this._registry);

  final AppFeatureFlagRepository _repository;
  final AppFeatureFlagDefinitionRegistry _registry;

  @protected
  @override
  Future<Either<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>>>
  execute() async {
    final flags = _registry.all.map(_repository.getFeatureFlag).toList();
    if (flags.isEmpty) {
      return const Left(FeatureFlagsNotFoundFailure());
    }
    return Right(flags);
  }

  @protected
  @override
  GetAllFeatureFlagsFailure mapErrorToFailure(Object e, StackTrace st) {
    return FeatureFlagsUnknownFailure(cause: e);
  }
}
