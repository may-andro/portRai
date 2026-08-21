import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/entity/_entity.dart';
import 'package:portrai/src/feature/experience/domain/exception/_exception.dart';
import 'package:portrai/src/feature/experience/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetExperienceFailure extends BasicFailure {
  const GetExperienceFailure({super.cause});
}

@Localizable('errorExperienceNotFound')
class ExperienceNotFoundFailure extends GetExperienceFailure {
  const ExperienceNotFoundFailure({super.cause});
}

@Localizable('errorExperienceNetwork')
class ExperienceNetworkFailure extends GetExperienceFailure {
  const ExperienceNetworkFailure({super.cause});
}

@Localizable('errorExperienceData')
class ExperienceDataFailure extends GetExperienceFailure {
  const ExperienceDataFailure({super.cause});
}

@Localizable('errorExperienceUnauthorized')
class ExperienceUnauthorizedFailure extends GetExperienceFailure {
  const ExperienceUnauthorizedFailure({super.cause});
}

@Localizable('errorExperienceUnknown')
class ExperienceUnknownFailure extends GetExperienceFailure {
  const ExperienceUnknownFailure({super.cause});
}

@register
class GetExperienceUseCase
    extends BaseUseCase<ExperienceEntity, String, GetExperienceFailure> {
  GetExperienceUseCase(this._repository);

  final ExperienceRepository _repository;

  @protected
  @override
  Future<Either<GetExperienceFailure, ExperienceEntity>> execute(
    String input,
  ) async {
    final experience = await _repository.getExperience(input);
    return Right(experience);
  }

  @protected
  @override
  GetExperienceFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ExperienceNotFoundException() => ExperienceNotFoundFailure(cause: e),
      ExperienceNetworkException() => ExperienceNetworkFailure(cause: e),
      ExperienceParsingException() => ExperienceDataFailure(cause: e),
      ExperienceUnauthorizedException() => ExperienceUnauthorizedFailure(
        cause: e,
      ),
      ExperienceCacheException() => ExperienceDataFailure(cause: e),
      _ => ExperienceUnknownFailure(cause: e),
    };
  }
}
