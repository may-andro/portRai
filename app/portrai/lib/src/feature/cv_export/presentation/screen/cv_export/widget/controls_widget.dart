part of 'content_widget.dart';

class _ControlsWidget extends StatelessWidget {
  const _ControlsWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: context.colorPalette.brand.primary.color,
            ),
            SizedBox(width: context.space()),
            Expanded(
              child: DSTextWidget(
                context.localizations.cvExportTitle,
                style: context.typography.headlineSmall,
                color: context.colorPalette.surface.onSurface,
              ),
            ),
          ],
        ),
        _SectionTitleWidget(context.localizations.cvExportTemplateSection),
        _TemplatePickerWidget(
          selectedTemplate: state.options.template,
          accent: state.options.accent,
        ),
        _SectionTitleWidget(context.localizations.cvExportAccentSection),
        _AccentPickerWidget(selectedAccent: state.options.accent),
        _SectionTitleWidget(context.localizations.cvExportContentSection),
        _SectionPickerWidget(selectedSections: state.options.sections),
        SizedBox(height: context.space(factor: 2)),
        _PhotoSwitchWidget(isIncluded: state.options.isPhotoIncluded),
        if (state.failure case final failure?) _FailureWidget(failure: failure),
      ],
    );
  }
}
