part of 'experience_list_widget.dart';

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({required this.description, required this.color});

  final String description;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      description,
      color: color,
      style: context.typography.emphasizedLabelLarge,
      isItalic: true,
    );
  }
}
