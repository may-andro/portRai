part of 'content_widget.dart';

const _maxSkillTags = 4;

class _JobOpeningCardWidget extends StatelessWidget {
  const _JobOpeningCardWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final textColor = palette.surface.onSurface;
    final skills = jobOpening.matchedSkills;
    final hiddenSkillCount = skills.length - _maxSkillTags;
    final companyAndLocation = [
      jobOpening.company,
      ?jobOpening.location,
    ].join(' · ');

    return DSSpotlightCardWidget(
      glowColor: JobFitTier.of(jobOpening.score).color(context),
      fillColor: textColor,
      background: ColoredBox(color: palette.surface.surfaceContainer.color),
      padding: EdgeInsets.all(context.space(factor: 2.5)),
      onTap: () {
        context.bloc.add(const JobOpeningClickEvent());
        context.pushScreen(
          JobOpeningModuleRoute.jobOpening,
          pathParameters: {JobOpeningScreen.routePathParameter: jobOpening.id},
        );
      },
      builder: (context, isHovering) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 1.5),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JobFitScoreWidget(score: jobOpening.score),
                const Spacer(),
                _ArrowWidget(isHovering: isHovering),
              ],
            ),
            JobOpeningPostedWidget(jobOpening: jobOpening),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 0.5),
              children: [
                DSTextWidget(
                  jobOpening.title,
                  style: context.typography.emphasizedTitleMedium,
                  color: textColor,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                DSTextWidget(
                  companyAndLocation,
                  style: context.typography.bodyMedium,
                  color: palette.neutral.grey7,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Spacer(),
            if (skills.isNotEmpty)
              Wrap(
                spacing: context.space(factor: 0.5),
                runSpacing: context.space(factor: 0.5),
                children: [
                  for (final skill in skills.take(_maxSkillTags))
                    DSTagWidget(label: skill),
                  if (hiddenSkillCount > 0)
                    DSTagWidget(label: '+$hiddenSkillCount'),
                ],
              ),
            Divider(height: 1, color: palette.outline.outlineVariant.color),
            Row(
              spacing: context.space(factor: 0.75),
              children: [
                Icon(
                  Icons.public_rounded,
                  size: 16,
                  color: palette.accent.color,
                ),
                Expanded(
                  child: DSTextWidget(
                    jobOpening.sourceName,
                    style: context.typography.labelMedium,
                    color: palette.neutral.grey7,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ArrowWidget extends StatelessWidget {
  const _ArrowWidget({required this.isHovering});

  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(context.space(factor: 0.75)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.accentContainer.color.withAlpha(isHovering ? 255 : 200),
      ),
      child: AnimatedRotation(
        turns: isHovering ? 0.125 : 0,
        duration: const Duration(milliseconds: 250),
        child: Icon(
          Icons.arrow_outward_rounded,
          size: 18,
          color: palette.brand.onTertiaryContainer.color,
        ),
      ),
    );
  }
}
