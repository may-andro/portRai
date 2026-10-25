import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/domain/exception/_exception.dart';
import 'package:portrai/src/feature/project/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RefreshProjectsFailure extends BasicFailure {
  const RefreshProjectsFailure({super.cause});
}

class RefreshProjectsNetworkFailure extends RefreshProjectsFailure {
  const RefreshProjectsNetworkFailure({super.cause});
}

class RefreshProjectsDataFailure extends RefreshProjectsFailure {
  const RefreshProjectsDataFailure({super.cause});
}

class RefreshProjectsUnknownFailure extends RefreshProjectsFailure {
  const RefreshProjectsUnknownFailure({super.cause});
}

/// Replaces the cached projects of the current locale with the latest ones.
/// The cached projects stay when the latest ones cannot be loaded.
@register
class RefreshProjectsUseCase
    extends BaseNoParamUseCase<void, RefreshProjectsFailure> {
  RefreshProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  @protected
  @override
  Future<Either<RefreshProjectsFailure, void>> execute() async {
    await _repository.refreshProjects();
    return const Right(null);
  }

  @protected
  @override
  RefreshProjectsFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ProjectNetworkException() ||
      ProjectUnauthorizedException() => RefreshProjectsNetworkFailure(cause: e),
      ProjectNotFoundException() ||
      ProjectParsingException() ||
      ProjectCacheException() => RefreshProjectsDataFailure(cause: e),
      _ => RefreshProjectsUnknownFailure(cause: e),
    };
  }
}
