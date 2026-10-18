part of 'content_widget.dart';

/// The content toggles as one group of selectable chips.
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
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Wrap(
          spacing: context.space(),
          runSpacing: context.space(),
          children: [
            for (final section in CvSection.values)
              _ContentChipWidget(
                label: section.label(context),
                isSelected: selectedSections.contains(section),
                onSelected: (_) {
                  context.bloc.add(ToggleCvSectionClickEvent(section));
                },
              ),
            _ContentChipWidget(
              label: context.localizations.cvExportIncludePhoto,
              isSelected: isPhotoIncluded,
              onSelected: (isIncluded) {
                context.bloc.add(
                  ToggleCvPhotoClickEvent(isIncluded: isIncluded),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentChipWidget extends StatelessWidget {
  const _ContentChipWidget({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final textColor = isSelected
        ? palette.inverseSurface
        : palette.neutral.grey1;

    return FilterChip(
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: textColor.color,
      elevation: 0,
      pressElevation: 0,
      surfaceTintColor: Colors.transparent,
      color: WidgetStatePropertyAll(
        isSelected ? palette.neutral.grey1.color : palette.inverseSurface.color,
      ),
      side: BorderSide(
        color: isSelected
            ? palette.neutral.grey1.color
            : palette.neutral.grey4.color,
      ),
      label: DSTextWidget(
        label,
        style: context.typography.labelLarge,
        color: textColor,
      ),
    );
  }
}
