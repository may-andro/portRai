part of 'content_widget.dart';

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.space(factor: 6)),
      child: Center(
        child: DSLoadingWidget(
          style: DSLoadingStyle.lottie,
          size: context.space(factor: 10),
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 4)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Column(
        spacing: context.space(factor: 2),
        children: [
          DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.talentSearch,
            width: context.space(factor: 26),
          ),
          DSTextWidget(
            context.localizations.jobOpeningsEmpty,
            style: context.typography.bodyLarge,
            color: palette.neutral.grey8,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
