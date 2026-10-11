import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

sealed class ResolveAssistantProjectsFailure extends BasicFailure {
  const ResolveAssistantProjectsFailure({super.cause});
}

final class AssistantProjectLimitExceededFailure
    extends ResolveAssistantProjectsFailure {
  const AssistantProjectLimitExceededFailure();
}

final class AssistantProjectInvalidIdFailure
    extends ResolveAssistantProjectsFailure {
  const AssistantProjectInvalidIdFailure();
}

final class AssistantProjectDuplicateIdFailure
    extends ResolveAssistantProjectsFailure {
  const AssistantProjectDuplicateIdFailure();
}

final class AssistantProjectUnknownIdFailure
    extends ResolveAssistantProjectsFailure {
  const AssistantProjectUnknownIdFailure();
}

final class AssistantProjectAmbiguousIdFailure
    extends ResolveAssistantProjectsFailure {
  const AssistantProjectAmbiguousIdFailure();
}

final class AssistantProjectsSourceFailure
    extends ResolveAssistantProjectsFailure {
  const AssistantProjectsSourceFailure({required GetProjectsFailure cause})
    : super(cause: cause);
}

final class ResolveAssistantProjectsUnknownFailure
    extends ResolveAssistantProjectsFailure {
  const ResolveAssistantProjectsUnknownFailure({super.cause});
}

/// Resolves exact source IDs, never generated project content.
@register
class ResolveAssistantProjectsUseCase
    extends
        BaseUseCase<
          List<ProjectEntity>,
          List<String>,
          ResolveAssistantProjectsFailure
        > {
  ResolveAssistantProjectsUseCase(this._getProjectsUseCase);

  final GetProjectsUseCase _getProjectsUseCase;

  static const maxProjects = 3;

  @protected
  @override
  Future<Either<ResolveAssistantProjectsFailure, List<ProjectEntity>>> execute(
    List<String> input,
  ) async {
    if (input.length > maxProjects) {
      return const Left(AssistantProjectLimitExceededFailure());
    }
    final ids = List<String>.of(input);
    if (ids.any((id) => id.trim().isEmpty)) {
      return const Left(AssistantProjectInvalidIdFailure());
    }
    final requestedIds = ids.toSet();
    if (requestedIds.length != ids.length) {
      return const Left(AssistantProjectDuplicateIdFailure());
    }
    if (ids.isEmpty) {
      return const Right([]);
    }

    final result = await _getProjectsUseCase();
    if (result.isLeft) {
      return Left(AssistantProjectsSourceFailure(cause: result.left));
    }

    final selected = <String, ProjectEntity>{};
    for (final project in result.right) {
      if (!requestedIds.contains(project.id)) continue;
      if (selected.containsKey(project.id)) {
        return const Left(AssistantProjectAmbiguousIdFailure());
      }
      selected[project.id] = project;
    }
    if (ids.any((id) => !selected.containsKey(id))) {
      return const Left(AssistantProjectUnknownIdFailure());
    }
    return Right(
      List<ProjectEntity>.unmodifiable(ids.map((id) => selected[id]!)),
    );
  }

  @protected
  @override
  ResolveAssistantProjectsFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      GetProjectsFailure() => AssistantProjectsSourceFailure(cause: e),
      _ => ResolveAssistantProjectsUnknownFailure(cause: e),
    };
  }
}
