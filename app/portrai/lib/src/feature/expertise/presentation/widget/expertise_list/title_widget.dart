part of 'expertise_list_widget.dart';

class _TitleWidget extends StatelessWidget {
  const _TitleWidget({
    required this.title,
    required this.maxLines,
    this.textAlign = TextAlign.left,
  });

  final String title;
  final TextAlign textAlign;
  final int maxLines;

  static double getHeight(BuildContext context, int maxLines) {
    return context.getTextHeight(
      context.typography.emphasizedTitleMedium,
      maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      title,
      textAlign: textAlign,
      color: context.colorPalette.neutral.grey9,
      style: context.typography.emphasizedTitleMedium,
      maxLines: maxLines,
      textOverflow: TextOverflow.ellipsis,
    );
  }
}
