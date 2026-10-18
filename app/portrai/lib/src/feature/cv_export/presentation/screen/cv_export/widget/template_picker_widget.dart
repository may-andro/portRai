part of 'content_widget.dart';

class _TemplatePickerWidget extends StatelessWidget {
  const _TemplatePickerWidget({
    required this.selectedTemplate,
    required this.accent,
  });

  final CvTemplate selectedTemplate;
  final CvAccent accent;

  @override
  Widget build(BuildContext context) {
    final spacing = context.space(factor: 1.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final template in CvTemplate.values)
              SizedBox(
                width: tileWidth,
                child: _TemplateTileWidget(
                  template: template,
                  accent: accent,
                  isSelected: template == selectedTemplate,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TemplateTileWidget extends StatelessWidget {
  const _TemplateTileWidget({
    required this.template,
    required this.accent,
    required this.isSelected,
  });

  final CvTemplate template;
  final CvAccent accent;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final radius = BorderRadius.circular(context.dimen.radiusLevel2.value);

    return Semantics(
      button: true,
      selected: isSelected,
      label: template.label(context),
      child: InkWell(
        borderRadius: radius,
        onTap: () => context.bloc.add(SelectCvTemplateClickEvent(template)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(context.space()),
          decoration: BoxDecoration(
            color: isSelected
                ? palette.brand.primaryContainer.color
                : palette.surface.surface.color,
            borderRadius: radius,
            border: Border.all(
              color: isSelected
                  ? palette.brand.primary.color
                  : palette.outline.outlineVariant.color,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 0.78,
                child: _TemplateThumbnailWidget(
                  template: template,
                  color: Color(accent.argb),
                ),
              ),
              SizedBox(height: context.space()),
              DSTextWidget(
                template.label(context),
                style: context.typography.labelLarge,
                color: palette.surface.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
