part of 'content_widget.dart';

class _TemplatePickerWidget extends StatelessWidget {
  const _TemplatePickerWidget({required this.selectedTemplate});

  final CvTemplate selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;

    return _OptionCardWidget(
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Column(
          spacing: context.space(factor: 1.5),
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<CvTemplate>(
                groupValue: selectedTemplate,
                backgroundColor: palette.neutral.grey1.color.withValues(
                  alpha: 0.18,
                ),
                thumbColor: palette.neutral.grey1.color,
                onValueChanged: (template) {
                  if (template == null) return;
                  context.bloc.add(SelectCvTemplateClickEvent(template));
                },
                children: {
                  for (final template in CvTemplate.values)
                    template: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.space()),
                      child: DSTextWidget(
                        template.label(context),
                        style: context.typography.labelLarge,
                        color: template == selectedTemplate
                            ? palette.inverseSurface
                            : palette.neutral.grey1,
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                },
              ),
            ),
            DSTextWidget(
              selectedTemplate.description(context),
              style: context.typography.bodyMedium,
              color: palette.neutral.grey3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
