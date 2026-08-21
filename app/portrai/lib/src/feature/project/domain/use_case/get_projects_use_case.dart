import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/domain/entity/_entity.dart';
import 'package:portrai/src/feature/project/domain/exception/_exception.dart';
import 'package:portrai/src/feature/project/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetProjectsFailure extends BasicFailure {
  const GetProjectsFailure({super.cause});
}

@Localizable('errorProjectNotFound')
class ProjectNotFoundFailure extends GetProjectsFailure {
  const ProjectNotFoundFailure({super.cause});
}

@Localizable('errorProjectNetwork')
class ProjectNetworkFailure extends GetProjectsFailure {
  const ProjectNetworkFailure({super.cause});
}

@Localizable('errorProjectData')
class ProjectDataFailure extends GetProjectsFailure {
  const ProjectDataFailure({super.cause});
}

@Localizable('errorProjectUnauthorized')
class ProjectUnauthorizedFailure extends GetProjectsFailure {
  const ProjectUnauthorizedFailure({super.cause});
}

@Localizable('errorProjectUnknown')
class ProjectUnknownFailure extends GetProjectsFailure {
  const ProjectUnknownFailure({super.cause});
}

@register
class GetProjectsUseCase
    extends BaseNoParamUseCase<List<ProjectEntity>, GetProjectsFailure> {
  GetProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  @protected
  @override
  Future<Either<GetProjectsFailure, List<ProjectEntity>>> execute() async {
    final projectList = await _repository.getProjects();
    return Right(projectList);
  }

  @protected
  @override
  GetProjectsFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ProjectNotFoundException() => ProjectNotFoundFailure(cause: e),
      ProjectNetworkException() => ProjectNetworkFailure(cause: e),
      ProjectParsingException() => ProjectDataFailure(cause: e),
      ProjectUnauthorizedException() => ProjectUnauthorizedFailure(cause: e),
      ProjectCacheException() => ProjectDataFailure(cause: e),
      _ => ProjectUnknownFailure(cause: e),
    };
  }
}
