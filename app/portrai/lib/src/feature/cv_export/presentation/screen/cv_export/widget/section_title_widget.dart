part of 'content_widget.dart';

class _SectionTitleWidget extends StatelessWidget {
  const _SectionTitleWidget(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.space()),
        child: DSTextWidget(
          title,
          style: context.typography.titleMedium,
          color: context.colorPalette.neutral.grey9,
        ),
      ),
    );
  }
}
