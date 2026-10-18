part of 'content_widget.dart';

class _SectionTitleWidget extends StatelessWidget {
  const _SectionTitleWidget(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.space(factor: 2),
        bottom: context.space(),
      ),
      child: DSTextWidget(
        title,
        style: context.typography.titleSmall,
        color: context.colorPalette.neutral.grey9,
      ),
    );
  }
}
