part of 'content_widget.dart';

class _SectionPickerWidget extends StatelessWidget {
  const _SectionPickerWidget({
    required this.selectedSections,
    required this.isPhotoIncluded,
  });

  final Set<CvSection> selectedSections;
  final bool isPhotoIncluded;

  @override
  Widget build(BuildContext context) {
    return _OptionCardWidget(
      child: Column(
        children: [
          for (final section in CvSection.values)
            _SwitchRowWidget(
              title: section.label(context),
              isOn: selectedSections.contains(section),
              onChanged: (_) {
                context.bloc.add(ToggleCvSectionClickEvent(section));
              },
            ),
          _SwitchRowWidget(
            title: context.localizations.cvExportIncludePhoto,
            isOn: isPhotoIncluded,
            onChanged: (isIncluded) {
              context.bloc.add(ToggleCvPhotoClickEvent(isIncluded: isIncluded));
            },
          ),
        ],
      ),
    );
  }
}

class _SwitchRowWidget extends StatelessWidget {
  const _SwitchRowWidget({
    required this.title,
    required this.isOn,
    required this.onChanged,
  });

  final String title;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 2),
      ),
      value: isOn,
      onChanged: onChanged,
      title: DSTextWidget(
        title,
        style: context.typography.titleMedium,
        color: context.colorPalette.neutral.grey1,
      ),
    );
  }
}
