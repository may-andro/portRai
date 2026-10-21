part of 'content_widget.dart';

const _maxSkillTags = 4;

class _JobOpeningCardWidget extends StatelessWidget {
  const _JobOpeningCardWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final textColor = palette.surface.onSurface;
    // Contract and freelance work stands out in its own color.
    final engagement = jobOpening.engagement;
    final highlight = palette.semantic.info;
    final skills = jobOpening.matchedSkills;
    final hiddenSkillCount = skills.length - _maxSkillTags;
    final companyAndLocation = [
      jobOpening.company,
      ?jobOpening.location,
    ].join(' · ');

    return DSSpotlightCardWidget(
      glowColor: JobFitTier.of(jobOpening.score).color(context),
      fillColor: engagement == null ? textColor : highlight,
      background: ColoredBox(
        color: engagement == null
            ? palette.surface.surfaceContainer.color
            : Color.alphaBlend(
                highlight.color.withAlpha(30),
                palette.surface.surfaceContainer.color,
              ),
      ),
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
            Wrap(
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                JobOpeningPostedWidget(jobOpening: jobOpening),
                if (engagement != null)
                  _EngagementChipWidget(engagement: engagement),
              ],
            ),
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

/// Names contract or freelance work in the card's highlight color.
class _EngagementChipWidget extends StatelessWidget {
  const _EngagementChipWidget({required this.engagement});

  final JobOpeningEngagement engagement;

  @override
  Widget build(BuildContext context) {
    final color = context.colorPalette.semantic.info;
    final localizations = context.localizations;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.25),
        vertical: context.space(factor: 0.5),
      ),
      decoration: BoxDecoration(
        color: color.color.withAlpha(36),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.color.withAlpha(110)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.5),
        children: [
          Icon(Icons.handshake_outlined, size: 16, color: color.color),
          DSTextWidget(
            switch (engagement) {
              JobOpeningEngagement.contract =>
                localizations.jobOpeningEngagementContract,
              JobOpeningEngagement.freelance =>
                localizations.jobOpeningEngagementFreelance,
            },
            style: context.typography.emphasizedLabelLarge,
            color: color,
          ),
        ],
      ),
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
