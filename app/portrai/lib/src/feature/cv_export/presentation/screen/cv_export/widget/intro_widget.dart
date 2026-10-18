part of 'content_widget.dart';

/// Short explanation of the screen, shown under the page header.
class _IntroWidget extends StatelessWidget {
  const _IntroWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.space(factor: 2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 2),
        children: [
          Icon(
            Icons.description_outlined,
            size: context.space(factor: 5),
            color: palette.neutral.grey9.color,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 0.5),
              children: [
                DSTextWidget(
                  context.localizations.cvExportTitle,
                  style: context.typography.emphasizedHeadlineSmall,
                  color: palette.neutral.grey10,
                ),
                DSTextWidget(
                  context.localizations.cvExportIntro,
                  style: context.typography.bodyMedium,
                  color: palette.neutral.grey8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
