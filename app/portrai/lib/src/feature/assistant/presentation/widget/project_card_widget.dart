part of 'assistant_project_cards_widget.dart';

class _ProjectCardWidget extends StatelessWidget {
  const _ProjectCardWidget({
    required this.project,
    required this.onProjectClick,
  });

  final ProjectEntity project;
  final ValueChanged<ProjectEntity>? onProjectClick;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final onClick = onProjectClick;
    return DSCardWidget(
      backgroundColor: palette.surface.surfaceContainer,
      radius: context.dimen.radiusLevel3,
      onTap: onClick == null ? null : () => onClick(project),
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 1.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DSTextWidget(
                    project.title,
                    color: palette.surface.onSurface,
                    style: context.typography.titleMedium,
                  ),
                ),
                if (onClick != null) ...[
                  const DSHorizontalSpacerWidget(1),
                  DSIconWidget(
                    Icons.chevron_right_rounded,
                    color: palette.surface.onSurface,
                    size: DSIconSize.small,
                  ),
                ],
              ],
            ),
            if (project.description.isNotEmpty) ...[
              const DSVerticalSpacerWidget(0.5),
              DSTextWidget(
                project.description,
                color: palette.surface.onSurface,
                style: context.typography.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
