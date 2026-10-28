part of 'content_widget.dart';

/// The week as seven day columns with each day's requests as time pills.
/// Arrows move a week at a time, and picking a day narrows the list to it.
class _WeekTimelineWidget extends StatelessWidget {
  const _WeekTimelineWidget({required this.state, required this.now});

  final LoadedState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final locale = Localizations.localeOf(context).toString();
    final weekDays = state.weekDays;
    final weekRequests = state.weekRequests(now);
    final thisWeek = appointmentWeekStartOf(now);
    final weekCount = weekRequests.values.fold(
      0,
      (count, requests) => count + requests.length,
    );
    final range =
        '${DateFormat.MMMd(locale).format(weekDays.first)} – '
        '${DateFormat.yMMMd(locale).format(weekDays.last)}';

    void showWeek(String label, DateTime weekStart) => context.bloc.add(
      AppointmentRequestsWeekClickEvent(label: label, weekStart: weekStart),
    );

    return Container(
      padding: EdgeInsets.all(context.space(factor: 2)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline.outlineVariant.color),
        boxShadow: [
          BoxShadow(
            color: palette.utility.shadow.color.withAlpha(18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 2),
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_view_week_rounded,
                color: palette.brand.primary.color,
              ),
              SizedBox(width: context.space()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSTextWidget(
                      localizations.appointmentRequestsWeekTitle,
                      style: context.typography.emphasizedTitleMedium,
                      color: palette.neutral.grey10,
                    ),
                    DSTextWidget(
                      '$range · ${localizations.appointmentRequestsWeekCount(weekCount)}',
                      style: context.typography.bodySmall,
                      color: palette.neutral.grey7,
                    ),
                  ],
                ),
              ),
              if (state.weekStart != thisWeek)
                IconButton(
                  tooltip: localizations.appointmentRequestsThisWeek,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => showWeek('this_week', thisWeek),
                  icon: const Icon(Icons.today_rounded),
                ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: localizations.appointmentRequestsPreviousWeek,
                onPressed: () => showWeek(
                  'previous_week',
                  DateTime(
                    state.weekStart.year,
                    state.weekStart.month,
                    state.weekStart.day - DateTime.daysPerWeek,
                  ),
                ),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: localizations.appointmentRequestsNextWeek,
                onPressed: () => showWeek(
                  'next_week',
                  DateTime(
                    state.weekStart.year,
                    state.weekStart.month,
                    state.weekStart.day + DateTime.daysPerWeek,
                  ),
                ),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: context.isMobile ? 0.5 : 1),
            children: [
              for (final day in weekDays)
                Expanded(
                  child: _DayColumnWidget(
                    day: day,
                    requests: weekRequests[day] ?? const [],
                    now: now,
                    isToday: day == appointmentDayOf(now),
                    isSelected: day == state.selectedDay,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayColumnWidget extends StatelessWidget {
  const _DayColumnWidget({
    required this.day,
    required this.requests,
    required this.now,
    required this.isToday,
    required this.isSelected,
  });

  /// Phones show dots instead of times, as the columns are narrow.
  static const _maxPills = 3;

  final DateTime day;
  final List<ReceivedAppointmentRequestEntity> requests;
  final DateTime now;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final locale = Localizations.localeOf(context).toString();
    final primary = palette.brand.primary;
    final onPrimary = palette.brand.onPrimary;
    final isMobile = context.isMobile;
    final shown = requests.take(_maxPills).toList();
    final hiddenCount = requests.length - shown.length;

    return Material(
      color: isSelected ? primary.color : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.bloc.add(AppointmentRequestsDayClickEvent(day)),
        child: AnimatedContainer(
          duration: 200.ms,
          constraints: BoxConstraints(
            minHeight: context.space(factor: isMobile ? 9 : 12),
          ),
          padding: EdgeInsets.symmetric(
            vertical: context.space(factor: 1.25),
            horizontal: context.space(factor: isMobile ? 0.25 : 0.75),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isToday && !isSelected
                  ? primary.color
                  : palette.neutral.transparent.color,
              width: 1.5,
            ),
          ),
          child: Column(
            spacing: context.space(factor: 0.75),
            children: [
              DSTextWidget(
                DateFormat.E(locale).format(day).capitalize,
                style: context.typography.labelMedium,
                color: isSelected ? onPrimary : palette.neutral.grey7,
                maxLines: 1,
                textOverflow: TextOverflow.clip,
              ),
              DSTextWidget(
                DateFormat.d(locale).format(day),
                style: context.typography.emphasizedTitleLarge,
                color: isSelected
                    ? onPrimary
                    : isToday
                    ? primary
                    : palette.neutral.grey10,
              ),
              if (isMobile)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 3,
                  runSpacing: 3,
                  children: [
                    for (final request in requests)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? onPrimary.color
                              : _RequestTone.of(
                                  context,
                                  request,
                                  now,
                                ).accent.color,
                        ),
                      ),
                  ],
                )
              else ...[
                for (final request in shown)
                  _TimePillWidget(
                    request: request,
                    now: now,
                    isOnPrimary: isSelected,
                  ),
                if (hiddenCount > 0)
                  DSTextWidget(
                    context.localizations.appointmentRequestsMoreCount(
                      hiddenCount,
                    ),
                    style: context.typography.labelSmall,
                    color: isSelected ? onPrimary : palette.neutral.grey7,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePillWidget extends StatelessWidget {
  const _TimePillWidget({
    required this.request,
    required this.now,
    required this.isOnPrimary,
  });

  final ReceivedAppointmentRequestEntity request;
  final DateTime now;
  final bool isOnPrimary;

  @override
  Widget build(BuildContext context) {
    final tone = _RequestTone.of(context, request, now);
    // A rounded box can't take a border on one side only, so the accent is a
    // strip inside the clip.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: isOnPrimary
            ? context.colorPalette.brand.onPrimary.color.withAlpha(220)
            : tone.container.color,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: tone.accent.color,
                child: const SizedBox(width: 3),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.space(factor: 0.375),
                  ),
                  child: DSTextWidget(
                    request.slotStart.formattedAppointmentTime(context),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    textOverflow: TextOverflow.fade,
                    softWrap: false,
                    style: context.typography.emphasizedLabelSmall,
                    color: tone.onContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
