part of 'content_widget.dart';

/// A dropdown of the free days, then the selected day's times as chips.
class _PickerWidget extends StatelessWidget {
  const _PickerWidget({
    required this.slotsByDay,
    required this.selectedDay,
    required this.selectedSlot,
    required this.isEnabled,
  });

  final Map<DateTime, List<DateTime>> slotsByDay;
  final DateTime? selectedDay;
  final DateTime? selectedSlot;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final daySlots = slotsByDay[selectedDay] ?? const <DateTime>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _formRowSpacing(context),
      children: [
        _DayDropdownWidget(
          days: slotsByDay.keys.toList(),
          selectedDay: selectedDay,
          isEnabled: isEnabled,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 0.75),
          children: [
            _LabelWidget(
              context.localizations.scheduleAppointmentFreeTimesTitle,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Wrap(
                key: ValueKey(selectedDay),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in daySlots)
                    _TimeTileWidget(
                      key: ValueKey(
                        'appointment_slot_${slot.toIso8601String()}',
                      ),
                      label: slot.formattedAppointmentTime(context),
                      isSelected: slot == selectedSlot,
                      onTap: isEnabled
                          ? () => context.bloc.add(
                              AppointmentSlotClickEvent(
                                label: 'appointment_slot_chip',
                                slot: slot,
                              ),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The free days to pick from, styled like the form's text fields.
class _DayDropdownWidget extends StatelessWidget {
  const _DayDropdownWidget({
    required this.days,
    required this.selectedDay,
    required this.isEnabled,
  });

  /// The free days at local midnight, earliest first.
  final List<DateTime> days;
  final DateTime? selectedDay;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabelWidget(context.localizations.scheduleAppointmentDayLabel),
        DropdownButtonFormField<DateTime>(
          // Follows a day picked again by the screen, such as after a reload.
          key: ValueKey(selectedDay),
          initialValue: selectedDay,
          isExpanded: true,
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
          dropdownColor: palette.surface.surfaceContainerHigh.color,
          icon: Icon(
            Icons.expand_more_rounded,
            color: palette.neutral.grey7.color,
          ),
          style: context.typography.bodyLarge.textStyle.copyWith(
            color: palette.neutral.grey10.color,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.calendar_month_rounded,
              color: palette.accent.color,
            ),
            enabledBorder: border(palette.neutral.grey4.color),
            disabledBorder: border(palette.neutral.grey4.color),
            focusedBorder: border(palette.accent.color, width: 2),
          ),
          items: [
            for (final day in days)
              DropdownMenuItem(
                value: day,
                child: Text(
                  day.formattedAppointmentDayLong(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: isEnabled
              ? (day) {
                  if (day == null) return;
                  context.bloc.add(
                    AppointmentDayClickEvent(
                      label: 'appointment_day_dropdown',
                      day: day,
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }
}

class _LabelWidget extends StatelessWidget {
  const _LabelWidget(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    // Matches the labels of the form's text fields.
    return DSTextWidget(
      label,
      style: context.typography.bodyMedium,
      color: context.colorPalette.neutral.grey9,
    );
  }
}

/// The selected tile's gradient, shared by days and times.
LinearGradient _selectedGradient(BuildContext context) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    context.colorPalette.brand.primary.color,
    context.colorPalette.brand.tertiary.color,
  ],
);

/// The height of a text field, so the chips line up with the form's fields.
const _timeChipHeight = 56.0;

/// A time chip as tall as a text field; the selected one shows a check.
class _TimeTileWidget extends StatelessWidget {
  const _TimeTileWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final radius = BorderRadius.circular(context.dimen.radiusLevel2.value);
    final foreground = isSelected
        ? palette.brand.onPrimary
        : palette.neutral.grey10;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: _timeChipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: isSelected ? _selectedGradient(context) : null,
              color: isSelected ? null : palette.surface.surface.color,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : palette.neutral.grey4.color,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  size: 16,
                  color: foreground.color,
                ),
                DSTextWidget(
                  label,
                  style: context.typography.emphasizedLabelLarge,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoSlotsWidget extends StatelessWidget {
  const _NoSlotsWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      spacing: context.space(factor: 1.5),
      children: [
        const DSLottieIllustrationWidget(
          illustration: DSLottieIllustration.appointment,
          width: 120,
        ),
        DSTextWidget(
          context.localizations.scheduleAppointmentNoSlots,
          style: context.typography.bodyLarge,
          color: palette.neutral.grey9,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
