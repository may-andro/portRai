part of 'content_widget.dart';

class _SectionPickerWidget extends StatelessWidget {
  const _SectionPickerWidget({required this.selectedSections});

  final Set<CvSection> selectedSections;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [
        for (final section in CvSection.values)
          FilterChip(
            selected: selectedSections.contains(section),
            selectedColor: context.colorPalette.brand.primaryContainer.color,
            label: DSTextWidget(
              section.label(context),
              style: context.typography.labelLarge,
              color: context.colorPalette.surface.onSurface,
            ),
            onSelected: (_) {
              context.bloc.add(ToggleCvSectionClickEvent(section));
            },
          ),
      ],
    );
  }
}
