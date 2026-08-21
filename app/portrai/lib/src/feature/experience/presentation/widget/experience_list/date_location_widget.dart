part of 'experience_list_widget.dart';

class _DateLocationWidget extends StatelessWidget {
  const _DateLocationWidget({
    required this.experience,
    this.isVerticalAligned = true,
  });

  final ExperienceEntity experience;
  final bool isVerticalAligned;

  static double getHeight(
    BuildContext context, {
    bool isVerticalAligned = true,
  }) {
    final itemHeight = _ItemWidget.getHeight(context);

    if (isVerticalAligned) {
      return (itemHeight * 2) + context.space(factor: 0.3);
    } else {
      return itemHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isVerticalAligned) {
      return Column(
        spacing: context.space(factor: 0.3),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ItemWidget(
            icon: Icons.calendar_month_rounded,
            label: experience.formattedExperienceDateRange,
          ),
          _ItemWidget(icon: Icons.pin_drop, label: experience.location),
        ],
      );
    }

    return Row(
      spacing: context.space(factor: 0.75),
      children: [
        Flexible(
          child: _ItemWidget(
            icon: Icons.calendar_month_rounded,
            label: experience.formattedExperienceDateRange,
          ),
        ),
        Flexible(
          child: _ItemWidget(icon: Icons.pin_drop, label: experience.location),
        ),
        Flexible(
          child: _ItemWidget(
            icon: Icons.work,
            label: experience.employmentType,
          ),
        ),
      ],
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static double getHeight(BuildContext context) {
    return context.getTextHeight(context.typography.labelSmall, 1);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorPalette.neutral.grey7;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.3),
      children: [
        Icon(
          icon,
          color: color.color,
          size: context.getTextHeight(context.typography.labelSmall, 1),
        ),
        Flexible(
          child: DSTextWidget(
            label,
            color: color,
            style: context.typography.labelSmall,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
