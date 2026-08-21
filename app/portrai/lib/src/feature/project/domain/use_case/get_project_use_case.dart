import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/domain/entity/_entity.dart';
import 'package:portrai/src/feature/project/domain/exception/_exception.dart';
import 'package:portrai/src/feature/project/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetProjectFailure extends BasicFailure {
  const GetProjectFailure({super.cause});
}

@Localizable('errorProjectNotFound')
class GetProjectNotFoundFailure extends GetProjectFailure {
  const GetProjectNotFoundFailure({super.cause});
}

@Localizable('errorProjectNetwork')
class GetProjectNetworkFailure extends GetProjectFailure {
  const GetProjectNetworkFailure({super.cause});
}

@Localizable('errorProjectData')
class GetProjectDataFailure extends GetProjectFailure {
  const GetProjectDataFailure({super.cause});
}

@Localizable('errorProjectUnauthorized')
class GetProjectUnauthorizedFailure extends GetProjectFailure {
  const GetProjectUnauthorizedFailure({super.cause});
}

@Localizable('errorProjectUnknown')
class GetProjectUnknownFailure extends GetProjectFailure {
  const GetProjectUnknownFailure({super.cause});
}

@register
class GetProjectUseCase
    extends BaseUseCase<ProjectEntity, String, GetProjectFailure> {
  GetProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @protected
  @override
  Future<Either<GetProjectFailure, ProjectEntity>> execute(String input) async {
    final project = await _repository.getProject(input);
    return Right(project);
  }

  @protected
  @override
  GetProjectFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ProjectNotFoundException() => GetProjectNotFoundFailure(cause: e),
      ProjectNetworkException() => GetProjectNetworkFailure(cause: e),
      ProjectParsingException() => GetProjectDataFailure(cause: e),
      ProjectUnauthorizedException() => GetProjectUnauthorizedFailure(cause: e),
      ProjectCacheException() => GetProjectDataFailure(cause: e),
      _ => GetProjectUnknownFailure(cause: e),
    };
  }
}
