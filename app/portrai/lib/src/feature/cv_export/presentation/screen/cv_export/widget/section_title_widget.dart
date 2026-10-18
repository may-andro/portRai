part of 'content_widget.dart';

class _SectionTitleWidget extends StatelessWidget {
  const _SectionTitleWidget(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.space(factor: 3),
        bottom: context.space(factor: 1.5),
      ),
      child: DSTextWidget(
        title.toUpperCase(),
        style: context.typography.labelMedium,
        color: context.colorPalette.surface.onSurfaceVariant,
      ),
    );
  }
}
