part of 'content_widget.dart';

class _ControlsWidget extends StatelessWidget {
  const _ControlsWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleWidget(context.localizations.cvExportTemplateSection),
        _TemplatePickerWidget(selectedTemplate: state.options.template),
        _SectionTitleWidget(context.localizations.cvExportAccentSection),
        _AccentPickerWidget(selectedAccent: state.options.accent),
        _SectionTitleWidget(context.localizations.cvExportContentSection),
        _SectionPickerWidget(
          selectedSections: state.options.sections,
          isPhotoIncluded: state.options.isPhotoIncluded,
        ),
        if (state.failure case final failure?) _FailureWidget(failure: failure),
      ],
    );
  }
}
