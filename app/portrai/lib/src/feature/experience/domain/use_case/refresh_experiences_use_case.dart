import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/exception/_exception.dart';
import 'package:portrai/src/feature/experience/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RefreshExperiencesFailure extends BasicFailure {
  const RefreshExperiencesFailure({super.cause});
}

class RefreshExperiencesNetworkFailure extends RefreshExperiencesFailure {
  const RefreshExperiencesNetworkFailure({super.cause});
}

class RefreshExperiencesDataFailure extends RefreshExperiencesFailure {
  const RefreshExperiencesDataFailure({super.cause});
}

class RefreshExperiencesUnknownFailure extends RefreshExperiencesFailure {
  const RefreshExperiencesUnknownFailure({super.cause});
}

/// Replaces the cached experiences of the current locale with the latest ones.
/// The cached experiences stay when the latest ones cannot be loaded.
@register
class RefreshExperiencesUseCase
    extends BaseNoParamUseCase<void, RefreshExperiencesFailure> {
  RefreshExperiencesUseCase(this._repository);

  final ExperienceRepository _repository;

  @protected
  @override
  Future<Either<RefreshExperiencesFailure, void>> execute() async {
    await _repository.refreshExperiences();
    return const Right(null);
  }

  @protected
  @override
  RefreshExperiencesFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ExperienceNetworkException() || ExperienceUnauthorizedException() =>
        RefreshExperiencesNetworkFailure(cause: e),
      ExperienceNotFoundException() ||
      ExperienceParsingException() ||
      ExperienceCacheException() => RefreshExperiencesDataFailure(cause: e),
      _ => RefreshExperiencesUnknownFailure(cause: e),
    };
  }
}
