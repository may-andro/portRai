part of 'personal_summary_widget.dart';

class _IntroWidget extends StatelessWidget {
  const _IntroWidget({
    required this.name,
    required this.title,
    required this.subtitle,
  });

  final String name;

  final String title;

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.5),
      children: [
        DSTextWidget(
          name,
          style: context.typography.emphasizedTitleLarge,
          color: context.colorPalette.neutral.grey10,
        ),
        DSTextWidget(
          title,
          style: context.typography.emphasizedTitleSmall,
          color: context.colorPalette.neutral.grey8,
        ),
        DSTextWidget(
          subtitle,
          style: context.typography.emphasizedTitleSmall,
          color: context.colorPalette.neutral.grey8,
        ),
      ],
    );
  }
}
