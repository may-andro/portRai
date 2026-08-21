part of 'content_widget.dart';

class _NameTitleWidget extends StatelessWidget {
  const _NameTitleWidget({
    required this.profile,
    this.alignment = CrossAxisAlignment.center,
  });

  final ProfileEntity profile;
  final CrossAxisAlignment alignment;

  static double getHeight(BuildContext context) {
    return context.getTextHeight(
          context.typography.emphasizedHeadlineMedium,
          1,
        ) +
        context.getTextHeight(context.typography.emphasizedTitleMedium, 1) +
        context.getTextHeight(context.typography.bodySmall, 1) +
        (context.space(factor: 0.5) * 2);
  }

  @override
  Widget build(BuildContext context) {
    final textAlign = alignment == CrossAxisAlignment.center
        ? TextAlign.center
        : TextAlign.left;

    return Column(
      crossAxisAlignment: alignment,
      spacing: context.space(factor: 0.5),
      children: [
        DSTextWidget(
          profile.fullName,
          style: context.typography.emphasizedHeadlineMedium,
          color: context.colorPalette.neutral.grey10,
          textAlign: textAlign,
        ),
        DSTextWidget(
          profile.subtitle,
          style: context.typography.emphasizedTitleMedium,
          color: context.colorPalette.brand.primary,
          textAlign: textAlign,
        ),
        DSTextWidget(
          '${profile.location.city}, ${profile.location.country}',
          style: context.typography.bodySmall,
          color: context.colorPalette.neutral.grey7,
          textAlign: textAlign,
        ),
      ],
    );
  }
}
