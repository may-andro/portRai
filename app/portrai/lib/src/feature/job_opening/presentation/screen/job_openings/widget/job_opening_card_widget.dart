part of 'content_widget.dart';

/// A compact card for one opening: the fit ring beside the title, then the
/// company, a line of facts and the job board it came from. A Flutter, Android or iOS job shows that platform's
/// logo in the background.
class _JobOpeningCardWidget extends StatelessWidget {
  const _JobOpeningCardWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final textColor = palette.surface.onSurface;
    // Contract and freelance work stands out in its own color.
    final engagement = jobOpening.engagement;
    final highlight = palette.semantic.info;
    final surface = engagement == null
        ? palette.surface.surfaceContainer.color
        : Color.alphaBlend(
            highlight.color.withAlpha(30),
            palette.surface.surfaceContainer.color,
          );
    final platform = jobOpening.platforms.firstOrNull;
    final now = DateTime.now();
    final companyAndLocation = [
      jobOpening.company,
      ?jobOpening.location,
    ].join(' · ');
    final facts = [
      if (engagement != null)
        switch (engagement) {
          JobOpeningEngagement.contract =>
            localizations.jobOpeningEngagementContract,
          JobOpeningEngagement.freelance =>
            localizations.jobOpeningEngagementFreelance,
        },
      localizations.jobOpeningPostedAgo(jobOpening.daysSincePosted(now)),
    ].join(' · ');

    return DSSpotlightCardWidget(
      glowColor: JobFitTier.of(jobOpening.score).color(context),
      fillColor: engagement == null ? textColor : highlight,
      background: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: surface),
          if (platform != null) _PlatformBackgroundWidget(platform: platform),
        ],
      ),
      padding: EdgeInsets.all(context.space(factor: 1.75)),
      onTap: () {
        context.bloc.add(const JobOpeningClickEvent());
        context.pushScreen(
          JobOpeningModuleRoute.jobOpening,
          pathParameters: {JobOpeningScreen.routePathParameter: jobOpening.id},
        );
      },
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 0.5),
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: context.space(factor: 0.5)),
              child: Row(
                spacing: context.space(factor: 1.5),
                children: [
                  JobFitScoreWidget(
                    score: jobOpening.score,
                    size: 48,
                    isAnimated: false,
                  ),
                  Expanded(
                    child: DSTextWidget(
                      jobOpening.title,
                      style: context.typography.emphasizedTitleSmall,
                      color: textColor,
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            DSTextWidget(
              companyAndLocation,
              style: context.typography.bodyMedium,
              color: palette.neutral.grey8,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
            DSTextWidget(
              facts,
              style: context.typography.labelMedium,
              color: jobOpening.isNew(now)
                  ? palette.semantic.success
                  : palette.neutral.grey7,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
            Row(
              spacing: context.space(factor: 0.5),
              children: [
                Icon(
                  Icons.public_rounded,
                  size: 14,
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

/// The platform's logo, oversized, tilted and cut off by the card's bottom
/// corner, over a soft glow in the platform's color.
class _PlatformBackgroundWidget extends StatelessWidget {
  const _PlatformBackgroundWidget({required this.platform});

  final JobOpeningPlatform platform;

  static const _logoSize = 120.0;

  @override
  Widget build(BuildContext context) {
    final glowColor = _PlatformLogoWidget.brandColorOf(platform, context);
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.1,
                  colors: [glowColor.withAlpha(46), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: -_logoSize * 0.14,
            bottom: -_logoSize * 0.24,
            child: Transform.rotate(
              angle: -0.26,
              child: Opacity(
                opacity: 0.22,
                child: _PlatformLogoWidget(platform: platform, size: _logoSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The platform's logo in its brand colors.
class _PlatformLogoWidget extends StatelessWidget {
  const _PlatformLogoWidget({required this.platform, required this.size});

  final JobOpeningPlatform platform;
  final double size;

  // Brand colors, the same in every theme.
  static const _flutterBlue = Color(0xFF02569B);
  static const _androidGreen = Color(0xFF3DDC84);

  /// Apple's logo is monochrome, so it follows the text color.
  static Color brandColorOf(
    JobOpeningPlatform platform,
    BuildContext context,
  ) => switch (platform) {
    JobOpeningPlatform.flutter => _flutterBlue,
    JobOpeningPlatform.android => _androidGreen,
    JobOpeningPlatform.ios => context.colorPalette.neutral.grey10.color,
  };

  @override
  Widget build(BuildContext context) {
    return switch (platform) {
      JobOpeningPlatform.flutter => FlutterLogo(size: size),
      JobOpeningPlatform.android || JobOpeningPlatform.ios => Icon(
        platform == JobOpeningPlatform.android
            ? Icons.android_rounded
            : Icons.apple_rounded,
        size: size,
        color: brandColorOf(platform, context),
      ),
    };
  }
}
