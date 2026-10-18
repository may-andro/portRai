part of 'content_widget.dart';

class _ControlsWidget extends StatelessWidget {
  const _ControlsWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSTextWidget(
          context.localizations.cvExportTitle,
          style: context.typography.headlineSmall,
          color: context.colorPalette.surface.onSurface,
        ),
        _SectionTitleWidget(context.localizations.cvExportTemplateSection),
        _TemplatePickerWidget(selectedTemplate: state.options.template),
        _SectionTitleWidget(context.localizations.cvExportAccentSection),
        _AccentPickerWidget(selectedAccent: state.options.accent),
        _SectionTitleWidget(context.localizations.cvExportContentSection),
        _SectionPickerWidget(selectedSections: state.options.sections),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: state.options.isPhotoIncluded,
          onChanged: (isIncluded) {
            context.bloc.add(ToggleCvPhotoClickEvent(isIncluded: isIncluded));
          },
          title: DSTextWidget(
            context.localizations.cvExportIncludePhoto,
            style: context.typography.bodyMedium,
            color: context.colorPalette.surface.onSurface,
          ),
        ),
        if (state.failure case final failure?) _FailureWidget(failure: failure),
        SizedBox(height: context.space(factor: 2)),
        _DownloadButtonWidget(state: state),
      ],
    );

    return context.isDesktop
        ? SingleChildScrollView(child: controls)
        : controls;
  }
}
