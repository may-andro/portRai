import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/entity/_entity.dart';
import 'package:portrai/src/feature/experience/domain/exception/_exception.dart';
import 'package:portrai/src/feature/experience/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetExperiencesFailure extends BasicFailure {
  const GetExperiencesFailure({super.cause});
}

@Localizable('errorExperiencesNotFound')
class ExperiencesNotFoundFailure extends GetExperiencesFailure {
  const ExperiencesNotFoundFailure({super.cause});
}

@Localizable('errorExperiencesNetwork')
class ExperiencesNetworkFailure extends GetExperiencesFailure {
  const ExperiencesNetworkFailure({super.cause});
}

@Localizable('errorExperiencesData')
class ExperiencesDataFailure extends GetExperiencesFailure {
  const ExperiencesDataFailure({super.cause});
}

@Localizable('errorExperiencesUnauthorized')
class ExperiencesUnauthorizedFailure extends GetExperiencesFailure {
  const ExperiencesUnauthorizedFailure({super.cause});
}

@Localizable('errorExperiencesUnknown')
class ExperiencesUnknownFailure extends GetExperiencesFailure {
  const ExperiencesUnknownFailure({super.cause});
}

@register
class GetExperiencesUseCase
    extends BaseNoParamUseCase<List<ExperienceEntity>, GetExperiencesFailure> {
  GetExperiencesUseCase(this._repository);

  final ExperienceRepository _repository;

  @protected
  @override
  Future<Either<GetExperiencesFailure, List<ExperienceEntity>>>
  execute() async {
    final experiences = await _repository.getExperiences();
    return Right(experiences);
  }

  @protected
  @override
  GetExperiencesFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      final ExperienceNotFoundException exception => ExperiencesNotFoundFailure(
        cause: exception,
      ),
      final ExperienceNetworkException exception => ExperiencesNetworkFailure(
        cause: exception,
      ),
      final ExperienceParsingException exception => ExperiencesDataFailure(
        cause: exception,
      ),
      final ExperienceUnauthorizedException exception =>
        ExperiencesUnauthorizedFailure(cause: exception),
      final ExperienceCacheException exception => ExperiencesDataFailure(
        cause: exception,
      ),
      _ => ExperiencesUnknownFailure(cause: e),
    };
  }
}
