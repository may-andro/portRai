part of 'experience_list_widget.dart';

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      description,
      color: context.colorPalette.neutral.grey7,
      style: context.typography.emphasizedLabelLarge,
      isItalic: true,
    );
  }
}
