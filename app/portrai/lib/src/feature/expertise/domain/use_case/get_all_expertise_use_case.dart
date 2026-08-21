import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/domain/entity/_entity.dart';
import 'package:portrai/src/feature/expertise/domain/exception/_exception.dart';
import 'package:portrai/src/feature/expertise/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetAllExpertiseFailure extends BasicFailure {
  const GetAllExpertiseFailure({super.cause});
}

@Localizable('errorExpertiseNotFound')
class ExpertiseNotFoundFailure extends GetAllExpertiseFailure {
  const ExpertiseNotFoundFailure({super.cause});
}

@Localizable('errorExpertiseNetwork')
class ExpertiseNetworkFailure extends GetAllExpertiseFailure {
  const ExpertiseNetworkFailure({super.cause});
}

@Localizable('errorExpertiseData')
class ExpertiseDataFailure extends GetAllExpertiseFailure {
  const ExpertiseDataFailure({super.cause});
}

@Localizable('errorExpertiseUnauthorized')
class ExpertiseUnauthorizedFailure extends GetAllExpertiseFailure {
  const ExpertiseUnauthorizedFailure({super.cause});
}

@Localizable('errorExpertiseUnknown')
class ExpertiseUnknownFailure extends GetAllExpertiseFailure {
  const ExpertiseUnknownFailure({super.cause});
}

@register
class GetAllExpertiseUseCase
    extends BaseNoParamUseCase<List<ExpertiseEntity>, GetAllExpertiseFailure> {
  GetAllExpertiseUseCase(this._repository);

  final ExpertiseRepository _repository;

  @protected
  @override
  Future<Either<GetAllExpertiseFailure, List<ExpertiseEntity>>>
  execute() async {
    final expertiseList = await _repository.getAllExpertise();
    return Right(expertiseList);
  }

  @protected
  @override
  GetAllExpertiseFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ExpertiseNotFoundException() => ExpertiseNotFoundFailure(cause: e),
      ExpertiseNetworkException() => ExpertiseNetworkFailure(cause: e),
      ExpertiseParsingException() => ExpertiseDataFailure(cause: e),
      ExpertiseUnauthorizedException() => ExpertiseUnauthorizedFailure(
        cause: e,
      ),
      ExpertiseCacheException() => ExpertiseDataFailure(cause: e),
      _ => ExpertiseUnknownFailure(cause: e),
    };
  }
}
