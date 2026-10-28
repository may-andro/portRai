part of 'content_widget.dart';

/// Shown when no request waits for an answer.
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
          const DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.appointment,
            width: 140,
          ),
          DSTextWidget(
            context.localizations.appointmentRequestsEmpty,
            style: context.typography.bodyLarge,
            color: palette.neutral.grey8,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
