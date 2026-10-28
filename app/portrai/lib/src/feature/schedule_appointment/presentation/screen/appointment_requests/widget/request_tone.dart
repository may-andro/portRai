part of 'content_widget.dart';

/// The colors, icon and label a request's state is shown with.
class _RequestTone {
  const _RequestTone({
    required this.accent,
    required this.container,
    required this.onContainer,
    required this.icon,
    required this.label,
  });

  factory _RequestTone.waiting(BuildContext context) {
    final semantic = context.colorPalette.semantic;
    return _RequestTone(
      accent: semantic.warning,
      container: semantic.warningContainer,
      onContainer: semantic.onWarningContainer,
      icon: Icons.hourglass_top_rounded,
      label: context.localizations.appointmentRequestStatusRequested,
    );
  }

  factory _RequestTone.accepted(BuildContext context) {
    final semantic = context.colorPalette.semantic;
    return _RequestTone(
      accent: semantic.success,
      container: semantic.successContainer,
      onContainer: semantic.onSuccessContainer,
      icon: Icons.check_circle_rounded,
      label: context.localizations.appointmentRequestStatusAccepted,
    );
  }

  factory _RequestTone.declined(BuildContext context) {
    final semantic = context.colorPalette.semantic;
    return _RequestTone(
      accent: semantic.error,
      container: semantic.errorContainer,
      onContainer: semantic.onErrorContainer,
      icon: Icons.cancel_rounded,
      label: context.localizations.appointmentRequestStatusDeclined,
    );
  }

  factory _RequestTone.unanswered(BuildContext context) {
    final palette = context.colorPalette;
    return _RequestTone(
      accent: palette.neutral.grey6,
      container: palette.surface.surfaceContainerHighest,
      onContainer: palette.neutral.grey8,
      icon: Icons.history_toggle_off_rounded,
      label: context.localizations.appointmentRequestStatusUnanswered,
    );
  }

  factory _RequestTone.of(
    BuildContext context,
    ReceivedAppointmentRequestEntity request,
    DateTime now,
  ) => switch (request.status) {
    AppointmentRequestStatus.accepted => _RequestTone.accepted(context),
    AppointmentRequestStatus.declined => _RequestTone.declined(context),
    AppointmentRequestStatus.requested when request.isAnswerableAt(now) =>
      _RequestTone.waiting(context),
    AppointmentRequestStatus.requested => _RequestTone.unanswered(context),
  };

  final DSColor accent;
  final DSColor container;
  final DSColor onContainer;
  final IconData icon;
  final String label;
}

/// A rounded label with an icon, in a request state's colors.
class _TonePillWidget extends StatelessWidget {
  const _TonePillWidget({required this.tone, this.label, this.icon});

  final _RequestTone tone;

  /// Replace the tone's own label and icon.
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.25),
        vertical: context.space(factor: 0.5),
      ),
      decoration: BoxDecoration(
        color: tone.container.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.5),
        children: [
          Icon(icon ?? tone.icon, size: 16, color: tone.onContainer.color),
          Flexible(
            child: DSTextWidget(
              label ?? tone.label,
              style: context.typography.emphasizedLabelMedium,
              color: tone.onContainer,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
