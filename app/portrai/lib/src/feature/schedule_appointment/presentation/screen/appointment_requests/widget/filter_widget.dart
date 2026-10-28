part of 'content_widget.dart';

/// The search field, a chip per request state with its count, and how many
/// requests are shown while the list is narrowed.
class _FilterWidget extends StatefulWidget {
  const _FilterWidget({required this.state, required this.now, super.key});

  final LoadedState state;
  final DateTime now;

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
    final now = widget.now;
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final chips = [
      for (final filter in AppointmentRequestsFilter.values)
        if (state.countOf(filter, now) case final count
            when count > 0 || state.filter == filter)
          _FilterChipWidget(
            filter: filter,
            count: count,
            isSelected: state.filter == filter,
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 1.5),
      children: [
        DSTextFieldWidget(
          controller: _searchController,
          hintText: localizations.appointmentRequestsSearchHint,
          suffixIcon: Icons.search_rounded,
          enabledBorderColor: palette.outline.outlineVariant,
          textInputAction: TextInputAction.search,
          onChanged: (searchQuery) => context.bloc.add(
            AppointmentRequestsSearchChangedEvent(searchQuery),
          ),
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
        if (state.isNarrowed)
          Row(
            children: [
              Expanded(
                child: DSTextWidget(
                  [
                    localizations.appointmentRequestsShowingCount(
                      state.visibleRequests(now).length,
                      state.requests.length,
                    ),
                    if (state.selectedDay case final day?)
                      day.formattedAppointmentDayLong(context),
                  ].join(' · '),
                  style: context.typography.labelLarge,
                  color: palette.neutral.grey7,
                ),
              ),
              DSButtonWidget(
                label: localizations.appointmentRequestsClearFilters,
                icon: Icons.filter_alt_off_outlined,
                variant: DSButtonVariant.text,
                size: DSButtonSize.small,
                isExpanded: false,
                onPressed: () => context.bloc.add(
                  const AppointmentRequestsClearFiltersClickEvent(),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget({
    required this.filter,
    required this.count,
    required this.isSelected,
  });

  final AppointmentRequestsFilter filter;
  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final tone = switch (filter) {
      AppointmentRequestsFilter.waiting => _RequestTone.waiting(context),
      AppointmentRequestsFilter.accepted => _RequestTone.accepted(context),
      AppointmentRequestsFilter.declined => _RequestTone.declined(context),
      AppointmentRequestsFilter.unanswered => _RequestTone.unanswered(context),
    };

    return FilterChip(
      selected: isSelected,
      onSelected: (_) =>
          context.bloc.add(AppointmentRequestsFilterClickEvent(filter)),
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: const StadiumBorder(),
      color: WidgetStatePropertyAll(
        isSelected
            ? tone.container.color
            : palette.surface.surfaceContainer.color,
      ),
      side: BorderSide(
        color: isSelected
            ? tone.accent.color
            : palette.outline.outlineVariant.color,
      ),
      avatar: Icon(
        tone.icon,
        size: 18,
        color: isSelected ? tone.onContainer.color : tone.accent.color,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.75),
        children: [
          DSTextWidget(
            tone.label,
            style: context.typography.emphasizedLabelLarge,
            color: isSelected ? tone.onContainer : palette.neutral.grey9,
          ),
          DSTextWidget(
            '$count',
            style: context.typography.labelMedium,
            color: isSelected ? tone.onContainer : palette.neutral.grey7,
          ),
        ],
      ),
    );
  }
}
