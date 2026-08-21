part of 'personal_summary_widget.dart';

class _SummaryWidget extends StatelessWidget {
  const _SummaryWidget({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DSTextWidget(
          '❝ ',
          style: context.summaryQuoteTextStyle,
          color: context.colorPalette.accent,
          isItalic: true,
        ),
        Expanded(
          child: DSTextWidget(
            summary,
            style: context.summaryTextStyle,
            color: context.colorPalette.neutral.grey9,
            textAlign: TextAlign.justify,
            isItalic: true,
          ),
        ),
      ],
    );
  }
}

extension on BuildContext {
  DSTextStyle get summaryQuoteTextStyle {
    return isiOS
        ? typography.emphasizedTitleLarge
        : typography.emphasizedDisplaySmall;
  }

  DSTextStyle get summaryTextStyle {
    return isiOS
        ? typography.emphasizedTitleSmall
        : typography.emphasizedTitleMedium;
  }
}
