part of 'content_widget.dart';

/// Shown before any visitor has asked for an appointment.
class _NoRequestsWidget extends StatelessWidget {
  const _NoRequestsWidget();

  @override
  Widget build(BuildContext context) {
    return _EmptyCardWidget(
      illustration: const DSLottieIllustrationWidget(
        illustration: DSLottieIllustration.appointment,
        width: 160,
      ),
      message: context.localizations.appointmentRequestsNoRequests,
    );
  }
}

/// Shown in the waiting section when every request has an answer.
class _CaughtUpWidget extends StatelessWidget {
  const _CaughtUpWidget();

  @override
  Widget build(BuildContext context) {
    return _EmptyCardWidget(
      illustration: Icon(
        Icons.task_alt_rounded,
        size: 40,
        color: context.colorPalette.semantic.success.color,
      ),
      message: context.localizations.appointmentRequestsEmpty,
    );
  }
}

/// Shown when the search, the filter or the day leave no requests.
class _NoResultsWidget extends StatelessWidget {
  const _NoResultsWidget();

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return _EmptyCardWidget(
      illustration: Icon(
        Icons.search_off_rounded,
        size: 40,
        color: context.colorPalette.neutral.grey7.color,
      ),
      message: localizations.appointmentRequestsNoResults,
      action: DSButtonWidget(
        label: localizations.appointmentRequestsClearFilters,
        icon: Icons.filter_alt_off_outlined,
        variant: DSButtonVariant.secondary,
        size: DSButtonSize.small,
        isExpanded: false,
        onPressed: () =>
            context.bloc.add(const AppointmentRequestsClearFiltersClickEvent()),
      ),
    );
  }
}

class _EmptyCardWidget extends StatelessWidget {
  const _EmptyCardWidget({
    required this.illustration,
    required this.message,
    this.action,
  });

  final Widget illustration;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 4)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Column(
        spacing: context.space(factor: 2),
        children: [
          illustration,
          DSTextWidget(
            message,
            style: context.typography.bodyLarge,
            color: palette.neutral.grey8,
            textAlign: TextAlign.center,
          ),
          ?action,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
