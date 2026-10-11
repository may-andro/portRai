import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/resolve_assistant_projects_use_case.dart';
import 'package:portrai/src/feature/project/project.dart';

part 'project_card_widget.dart';

/// Renders resolved source projects without generation or navigation.
///
/// Callers resolve exact IDs with [ResolveAssistantProjectsUseCase] first.
/// An omitted [onProjectClick] renders noninteractive summaries.
class AssistantProjectCardsWidget extends StatelessWidget {
  AssistantProjectCardsWidget({
    super.key,
    required List<ProjectEntity> projects,
    this.onProjectClick,
  }) : projects = List<ProjectEntity>.unmodifiable(projects) {
    if (this.projects.length > ResolveAssistantProjectsUseCase.maxProjects) {
      throw ArgumentError.value(projects, 'projects', 'At most 3 projects');
    }
    final ids = <String>{};
    for (final project in this.projects) {
      if (project.id.trim().isEmpty || !ids.add(project.id)) {
        throw ArgumentError.value(
          project.id,
          'projects',
          'Project IDs must be nonblank and unique',
        );
      }
    }
  }

  final List<ProjectEntity> projects;
  final ValueChanged<ProjectEntity>? onProjectClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < projects.length; index++) ...[
          if (index > 0) const DSVerticalSpacerWidget(1),
          _ProjectCardWidget(
            project: projects[index],
            onProjectClick: onProjectClick,
          ),
        ],
      ],
    );
  }
}
