part of 'content_widget.dart';

/// The search field, a chip for each filter that matches at least one
/// opening, and how many openings are shown while the list is narrowed.
class _SearchWidget extends StatefulWidget {
  const _SearchWidget({required this.state});

  final JobOpeningsState state;

  @override
  State<_SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<_SearchWidget> {
  late final _searchController = TextEditingController(
    text: widget.state.searchQuery,
  );

  @override
  void didUpdateWidget(_SearchWidget oldWidget) {
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

  int _matchCountOf(JobOpeningsFilter filter, DateTime now) => widget
      .state
      .jobOpenings
      .where((jobOpening) => filter.matches(jobOpening, now))
      .length;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final now = DateTime.now();
    final chips = [
      for (final filter in JobOpeningsFilter.values)
        if (_matchCountOf(filter, now) case final matchCount
            when matchCount > 0 || state.filters.contains(filter))
          _FilterChipWidget(
            filter: filter,
            matchCount: matchCount,
            isSelected: state.filters.contains(filter),
          ),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: context.space(factor: 2.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 1.5),
        children: [
          DSTextFieldWidget(
            controller: _searchController,
            hintText: localizations.jobOpeningsSearchHint,
            suffixIcon: Icons.search_rounded,
            enabledBorderColor: palette.outline.outlineVariant,
            textInputAction: TextInputAction.search,
            onChanged: (searchQuery) =>
                context.bloc.add(JobOpeningsSearchChangedEvent(searchQuery)),
          ),
          // Phones scroll the chips sideways instead of wrapping them.
          if (chips.isNotEmpty && context.isMobile)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(spacing: context.space(), children: chips),
            )
          else if (chips.isNotEmpty)
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
                    localizations.jobOpeningsShowingCount(
                      state.visibleJobOpenings(now).length,
                      state.jobOpenings.length,
                    ),
                    style: context.typography.labelLarge,
                    color: palette.neutral.grey7,
                  ),
                ),
                DSButtonWidget(
                  label: localizations.jobOpeningsClearFilters,
                  icon: Icons.filter_alt_off_outlined,
                  variant: DSButtonVariant.text,
                  size: DSButtonSize.small,
                  isExpanded: false,
                  onPressed: () => context.bloc.add(
                    const JobOpeningsClearFiltersClickEvent(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget({
    required this.filter,
    required this.matchCount,
    required this.isSelected,
  });

  final JobOpeningsFilter filter;
  final int matchCount;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final accent = palette.accent.color;
    final iconColor = isSelected ? accent : palette.neutral.grey7.color;
    final label = switch (filter) {
      JobOpeningsFilter.flutter => localizations.jobOpeningsFilterFlutter,
      JobOpeningsFilter.android => localizations.jobOpeningsFilterAndroid,
      JobOpeningsFilter.ios => localizations.jobOpeningsFilterIos,
      JobOpeningsFilter.contract => localizations.jobOpeningEngagementContract,
      JobOpeningsFilter.freelance =>
        localizations.jobOpeningEngagementFreelance,
      JobOpeningsFilter.strongFit => localizations.jobOpeningFitStrong,
      JobOpeningsFilter.recent => localizations.jobOpeningsFilterRecent,
    };
    final avatar = switch (filter) {
      JobOpeningsFilter.flutter => const _PlatformLogoWidget(
        platform: JobOpeningPlatform.flutter,
        size: 16,
      ),
      JobOpeningsFilter.android => const _PlatformLogoWidget(
        platform: JobOpeningPlatform.android,
        size: 18,
      ),
      JobOpeningsFilter.ios => const _PlatformLogoWidget(
        platform: JobOpeningPlatform.ios,
        size: 18,
      ),
      JobOpeningsFilter.contract => Icon(
        Icons.handshake_outlined,
        size: 18,
        color: iconColor,
      ),
      JobOpeningsFilter.freelance => Icon(
        Icons.work_history_outlined,
        size: 18,
        color: iconColor,
      ),
      JobOpeningsFilter.strongFit => Icon(
        Icons.auto_awesome_rounded,
        size: 18,
        color: iconColor,
      ),
      JobOpeningsFilter.recent => Icon(
        Icons.schedule_rounded,
        size: 18,
        color: iconColor,
      ),
    };

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => context.bloc.add(JobOpeningsFilterClickEvent(filter)),
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
      avatar: avatar,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.75),
        children: [
          DSTextWidget(
            label,
            style: context.typography.emphasizedLabelLarge,
            color: isSelected ? palette.neutral.grey10 : palette.neutral.grey9,
          ),
          DSTextWidget(
            '$matchCount',
            style: context.typography.labelMedium,
            color: palette.neutral.grey7,
          ),
        ],
      ),
    );
  }
}
