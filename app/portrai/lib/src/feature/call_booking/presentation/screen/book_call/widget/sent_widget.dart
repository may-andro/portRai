part of 'content_widget.dart';

/// A card confirming the request, with the animated calendar and a burst of
/// confetti.
class _SentWidget extends StatelessWidget {
  const _SentWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 4)),
        child: Column(
          spacing: context.space(factor: 2),
          children: [
            const DSLottieIllustrationWidget(
              illustration: DSLottieIllustration.appointment,
              width: 140,
            ),
            DSTextWidget(
              localizations.bookCallSentTitle,
              style: context.typography.emphasizedHeadlineMedium,
              color: palette.neutral.grey10,
              textAlign: TextAlign.center,
            ),
            DSTextWidget(
              localizations.bookCallSentDescription,
              style: context.typography.bodyLarge,
              color: palette.neutral.grey7,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.space()),
            DSButtonWidget(
              label: localizations.bookCallSentDone,
              isExpanded: false,
              onPressed: () {
                // A shared link opens the screen on its own, with nothing to
                // go back to.
                if (Navigator.of(context).canPop()) {
                  context.popScreen();
                } else {
                  context.goLocation('/');
                }
              },
            ),
          ],
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        // Plays once over the card, without catching its taps.
        Positioned.fill(
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) => OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: DSLottieIllustrationWidget(
                  illustration: DSLottieIllustration.confetti,
                  width: constraints.maxWidth * 1.4,
                  playback: DSLottiePlayback.once,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
