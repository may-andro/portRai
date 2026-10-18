part of 'content_widget.dart';

class _ControlsWidget extends StatelessWidget {
  const _ControlsWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionWidget(
          title: context.localizations.cvExportTemplateSection,
          hint: context.localizations.cvExportTemplateHint,
          child: _TemplatePickerWidget(
            selectedTemplate: state.options.template,
          ),
        ),
        _SectionWidget(
          title: context.localizations.cvExportAccentSection,
          hint: context.localizations.cvExportAccentHint,
          child: _AccentPickerWidget(selectedAccent: state.options.accent),
        ),
        _SectionWidget(
          title: context.localizations.cvExportContentSection,
          hint: context.localizations.cvExportContentHint,
          child: _SectionPickerWidget(
            selectedSections: state.options.sections,
            isPhotoIncluded: state.options.isPhotoIncluded,
          ),
        ),
        if (state.options.isPhotoIncluded &&
            state.document.photoUrls.length > 1)
          _SectionWidget(
            title: context.localizations.cvExportPhotoSection,
            hint: context.localizations.cvExportPhotoHint,
            child: _PhotoPickerWidget(
              photoUrls: state.document.photoUrls,
              selectedPhotoUrl:
                  state.options.photoUrl ?? state.document.photoUrl,
            ),
          ),
        if (state.failure case final failure?) _FailureWidget(failure: failure),
      ],
    );
  }
}
