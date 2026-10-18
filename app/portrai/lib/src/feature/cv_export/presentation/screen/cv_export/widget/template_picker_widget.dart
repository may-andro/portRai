part of 'content_widget.dart';

class _TemplatePickerWidget extends StatelessWidget {
  const _TemplatePickerWidget({required this.selectedTemplate});

  final CvTemplate selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [
        for (final template in CvTemplate.values)
          ChoiceChip(
            selected: template == selectedTemplate,
            selectedColor: context.colorPalette.brand.primaryContainer.color,
            label: DSTextWidget(
              template.label(context),
              style: context.typography.labelLarge,
              color: context.colorPalette.surface.onSurface,
            ),
            onSelected: (_) {
              context.bloc.add(SelectCvTemplateClickEvent(template));
            },
          ),
      ],
    );
  }
}
