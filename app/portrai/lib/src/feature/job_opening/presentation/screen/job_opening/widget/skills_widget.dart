part of 'content_widget.dart';

class _SkillsWidget extends StatelessWidget {
  const _SkillsWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final palette = context.colorPalette;
    final groups = [
      if (jobOpening.matchedSkills.isNotEmpty)
        _SkillGroupWidget(
          title: localizations.jobOpeningMatchedSkillsTitle,
          skills: jobOpening.matchedSkills,
          icon: Icons.check_rounded,
          color: palette.semantic.success,
        ),
      if (jobOpening.missingSkills.isNotEmpty)
        _SkillGroupWidget(
          title: localizations.jobOpeningMissingSkillsTitle,
          skills: jobOpening.missingSkills,
          icon: Icons.add_rounded,
          color: palette.semantic.warning,
        ),
    ];

    if (context.isMobile || groups.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 2),
        children: groups,
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 2),
        children: [for (final group in groups) Expanded(child: group)],
      ),
    );
  }
}

class _SkillGroupWidget extends StatelessWidget {
  const _SkillGroupWidget({
    required this.title,
    required this.skills,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> skills;
  final IconData icon;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 2.5)),
      decoration: BoxDecoration(
        color: palette.surface.surface.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: color.color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          DSTextWidget(
            title,
            style: context.typography.emphasizedTitleMedium,
            color: palette.neutral.grey10,
          ),
          Wrap(
            spacing: context.space(),
            runSpacing: context.space(),
            children: [
              for (final skill in skills)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.space(factor: 1.25),
                    vertical: context.space(factor: 0.75),
                  ),
                  decoration: BoxDecoration(
                    color: color.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: color.color.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: context.space(factor: 0.5),
                    children: [
                      Icon(icon, size: 16, color: color.color),
                      DSTextWidget(
                        skill,
                        style: context.typography.emphasizedLabelLarge,
                        color: palette.neutral.grey10,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
