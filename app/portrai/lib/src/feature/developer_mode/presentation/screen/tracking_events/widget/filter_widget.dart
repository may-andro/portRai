part of 'content_widget.dart';

/// The search field, the area filter, a chip for each event name and how many
/// events are shown.
class _FilterWidget extends StatefulWidget {
  const _FilterWidget({required this.state});

  final TrackingEventsLoadedState state;

  @override
  State<_FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<_FilterWidget> {
  late final _searchController = TextEditingController(
    text: widget.state.searchQuery,
  );

  @override
  void didUpdateWidget(_FilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clearing the filters also clears the search.
    final searchQuery = widget.state.searchQuery;
    if (searchQuery != _searchController.text) {
      _searchController.text = searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final searchField = DSTextFieldWidget(
      controller: _searchController,
      hintText: localizations.trackingEventsSearchHint,
      suffixIcon: Icons.search_rounded,
      enabledBorderColor: palette.outline.outlineVariant,
      textInputAction: TextInputAction.search,
      onChanged: (searchQuery) =>
          context.bloc.add(TrackingEventsSearchChangedEvent(searchQuery)),
    );
    final areaFilter = _AreaFilterWidget(
      areaCounts: state.areaCounts,
      selectedArea: state.areaFilter,
    );
    final chips = [
      for (final MapEntry(key: name, value: count) in state.nameCounts.entries)
        _NameFilterChipWidget(
          name: name,
          count: count,
          isSelected: state.nameFilters.contains(name),
        ),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: context.space(factor: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 1.5),
        children: [
          // Wider screens keep the search and the area filter on one line.
          if (context.isMobile) ...[
            searchField,
            areaFilter,
          ] else
            Row(
              spacing: context.space(factor: 2),
              children: [
                Expanded(flex: 2, child: searchField),
                Expanded(child: areaFilter),
              ],
            ),
          // Phones scroll the chips sideways instead of wrapping them.
          if (context.isMobile)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(spacing: context.space(), children: chips),
            )
          else
            Wrap(
              spacing: context.space(),
              runSpacing: context.space(),
              children: chips,
            ),
          Row(
            children: [
              Expanded(
                child: DSTextWidget(
                  state.isNarrowed
                      ? localizations.trackingEventsShowingCount(
                          state.visibleTrackingEvents.length,
                          state.trackingEvents.length,
                        )
                      : localizations.trackingEventsCount(
                          state.trackingEvents.length,
                        ),
                  style: context.typography.labelLarge,
                  color: palette.neutral.grey7,
                ),
              ),
              if (state.isNarrowed)
                DSButtonWidget(
                  label: localizations.trackingEventsClearFilters,
                  icon: Icons.filter_alt_off_outlined,
                  variant: DSButtonVariant.text,
                  size: DSButtonSize.small,
                  isExpanded: false,
                  onPressed: () => context.bloc.add(
                    const TrackingEventsClearFiltersClickEvent(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaFilterWidget extends StatelessWidget {
  const _AreaFilterWidget({
    required this.areaCounts,
    required this.selectedArea,
  });

  final Map<String, int> areaCounts;
  final String? selectedArea;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return DropdownButtonFormField<String?>(
      // Rebuilds the field when the area is cleared from outside it.
      key: ValueKey(selectedArea),
      initialValue: selectedArea,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: localizations.trackingEventsAreaFilterLabel,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(child: Text(localizations.trackingEventsAllAreas)),
        for (final MapEntry(key: area, value: count) in areaCounts.entries)
          DropdownMenuItem(
            value: area,
            child: Text('$area ($count)', overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (area) =>
          context.bloc.add(TrackingEventsAreaFilterClickEvent(area)),
    );
  }
}

class _NameFilterChipWidget extends StatelessWidget {
  const _NameFilterChipWidget({
    required this.name,
    required this.count,
    required this.isSelected,
  });

  final String name;
  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    return FilterChip(
      selected: isSelected,
      onSelected: (_) =>
          context.bloc.add(TrackingEventsNameFilterClickEvent(name)),
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: const StadiumBorder(),
      color: WidgetStatePropertyAll(
        isSelected
            ? accent.withAlpha(40)
            : palette.surface.surfaceContainer.color,
      ),
      side: BorderSide(
        color: isSelected ? accent : palette.outline.outlineVariant.color,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.75),
        children: [
          DSTextWidget(
            name,
            style: context.typography.emphasizedLabelLarge,
            color: isSelected ? palette.neutral.grey10 : palette.neutral.grey9,
          ),
          DSTextWidget(
            '$count',
            style: context.typography.labelMedium,
            color: palette.neutral.grey7,
          ),
        ],
      ),
    );
  }
}
