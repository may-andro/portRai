part of 'content_widget.dart';

/// Matched skills first, then the ones the job also asks for. Each group
/// spans the full width, so long lists flow across the page instead of
/// growing one column.
class _SkillsWidget extends StatelessWidget {
  const _SkillsWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final palette = context.colorPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 2),
      children: [
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
      ],
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
      padding: EdgeInsets.all(
        context.space(factor: context.isMobile ? 2 : 2.5),
      ),
      decoration: BoxDecoration(
        color: palette.surface.surface.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: color.color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          Row(
            spacing: context.space(),
            children: [
              Flexible(
                child: DSTextWidget(
                  title,
                  style: context.typography.emphasizedTitleMedium,
                  color: palette.neutral.grey10,
                ),
              ),
              DSTextWidget(
                '${skills.length}',
                style: context.typography.emphasizedLabelLarge,
                color: color,
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                for (final skill in skills)
                  _SkillChipWidget(
                    skill: skill,
                    icon: icon,
                    color: color,
                    maxWidth: constraints.maxWidth,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shrinks to fit [maxWidth] and wraps a long name onto a second line.
class _SkillChipWidget extends StatelessWidget {
  const _SkillChipWidget({
    required this.skill,
    required this.icon,
    required this.color,
    required this.maxWidth,
  });

  final String skill;
  final IconData icon;
  final DSColor color;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 1.25),
          vertical: context.space(factor: 0.5),
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
            Flexible(
              child: DSTextWidget(
                skill,
                style: context.typography.emphasizedLabelLarge,
                color: context.colorPalette.neutral.grey10,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
