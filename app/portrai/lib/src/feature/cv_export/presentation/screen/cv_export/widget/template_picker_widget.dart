part of 'content_widget.dart';

class _TemplatePickerWidget extends StatelessWidget {
  const _TemplatePickerWidget({required this.selectedTemplate});

  final CvTemplate selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;

    return _OptionCardWidget(
      child: Column(
        children: [
          for (final template in CvTemplate.values)
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.space(factor: 2),
              ),
              title: DSTextWidget(
                template.label(context),
                style: context.typography.titleMedium,
                color: palette.neutral.grey1,
              ),
              subtitle: DSTextWidget(
                template.description(context),
                style: context.typography.bodyMedium,
                color: palette.neutral.grey3,
              ),
              trailing: Icon(
                template == selectedTemplate
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: context.iconSize,
                color: template == selectedTemplate
                    ? palette.neutral.grey1.color
                    : palette.neutral.grey3.color,
              ),
              onTap: () {
                context.bloc.add(SelectCvTemplateClickEvent(template));
              },
            ),
        ],
      ),
    );
  }
}
