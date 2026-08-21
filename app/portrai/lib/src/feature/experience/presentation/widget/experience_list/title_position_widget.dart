part of 'experience_list_widget.dart';

class _TitlePositionWidget extends StatelessWidget {
  const _TitlePositionWidget({
    required this.experience,
    this.isVerticalAligned = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final ExperienceEntity experience;
  final bool isVerticalAligned;
  final CrossAxisAlignment crossAxisAlignment;

  static double getHeight(
    BuildContext context, {
    bool isVerticalAligned = true,
  }) {
    if (isVerticalAligned) {
      return context.getTextHeight(context.typography.emphasizedBodyLarge, 1) +
          context.getTextHeight(context.typography.bodyLarge, 1);
    } else {
      return context.getTextHeight(context.typography.emphasizedTitleLarge, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isVerticalAligned) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          DSTextWidget(
            experience.position,
            color: context.colorPalette.neutral.grey10,
            style: context.typography.emphasizedBodyLarge,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
          DSTextWidget(
            experience.company,
            color: context.colorPalette.neutral.grey8,
            style: context.typography.bodyLarge,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            isItalic: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        DSTextWidget(
          experience.position,
          style: context.typography.emphasizedTitleLarge,
          color: context.colorPalette.neutral.grey10,
        ),
        const DSHorizontalSpacerWidget(0.5),
        DSTextWidget(
          'at',
          style: context.typography.bodyLarge,
          color: context.colorPalette.neutral.grey8,
        ),
        const DSHorizontalSpacerWidget(0.5),
        Flexible(
          child: DSTextWidget(
            experience.company,
            style: context.typography.titleLarge,
            color: context.colorPalette.neutral.grey8,
            isItalic: true,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
