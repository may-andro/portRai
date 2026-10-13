part of 'experience_list_widget.dart';

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.5),
      children: [
        Icon(
          icon,
          color: color.color,
          size: context.getTextHeight(context.typography.labelMedium, 1),
        ),
        Flexible(
          child: DSTextWidget(
            label,
            color: color,
            style: context.typography.labelMedium,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
