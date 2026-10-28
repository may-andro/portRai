part of 'content_widget.dart';

/// One request: its time, the visitor and their message, and, while it can
/// be answered, the buttons to accept or decline it.
class _RequestCardWidget extends StatelessWidget {
  const _RequestCardWidget({
    required this.request,
    required this.isAnswerable,
    required this.isDeciding,
    super.key,
  });

  final ReceivedAppointmentRequestEntity request;
  final bool isAnswerable;
  final bool isDeciding;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final time = localizations.appointmentRequestTime(
      request.slotStart.toLocal().formattedAppointmentDayLong(context),
      request.slotStart.formattedAppointmentTime(context),
      request.slotEnd.formattedAppointmentTime(context),
    );

    return Container(
      padding: EdgeInsets.all(context.space(factor: 2.5)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(),
        children: [
          Wrap(
            spacing: context.space(),
            runSpacing: context.space(),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DSInfoChipWidget(icon: Icons.event_outlined, label: time),
              _StatusWidget(request: request, isAnswerable: isAnswerable),
            ],
          ),
          DSTextWidget(
            request.name,
            style: context.typography.emphasizedTitleMedium,
            color: palette.neutral.grey10,
          ),
          DSTextWidget(
            request.email,
            style: context.typography.bodyMedium,
            color: palette.neutral.grey7,
          ),
          DSTextWidget(
            request.topic,
            style: context.typography.titleSmall,
            color: palette.neutral.grey9,
          ),
          if (request.message.isNotEmpty)
            DSTextWidget(
              request.message,
              style: context.typography.bodyMedium,
              color: palette.neutral.grey8,
            ),
          if (isAnswerable) ...[
            SizedBox(height: context.space()),
            Wrap(
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                DSButtonWidget(
                  label: localizations.appointmentRequestAccept,
                  icon: Icons.check_rounded,
                  size: DSButtonSize.small,
                  isExpanded: false,
                  isLoading: isDeciding,
                  isDisabled: isDeciding,
                  onPressed: () => _decide(context, AppointmentDecision.accept),
                ),
                DSButtonWidget(
                  label: localizations.appointmentRequestDecline,
                  icon: Icons.close_rounded,
                  variant: DSButtonVariant.secondary,
                  size: DSButtonSize.small,
                  isExpanded: false,
                  isDisabled: isDeciding,
                  onPressed: () =>
                      _decide(context, AppointmentDecision.decline),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Asks first, since the visitor gets an email with the answer.
  Future<void> _decide(
    BuildContext context,
    AppointmentDecision decision,
  ) async {
    final bloc = context.bloc;
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _DecisionDialogWidget(name: request.name, decision: decision),
    );
    if (isConfirmed != true) return;
    bloc.add(
      AppointmentRequestDecisionClickEvent(
        requestId: request.id,
        decision: decision,
      ),
    );
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({required this.request, required this.isAnswerable});

  final ReceivedAppointmentRequestEntity request;
  final bool isAnswerable;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final (icon, label) = switch (request.status) {
      AppointmentRequestStatus.accepted => (
        Icons.check_circle_outline_rounded,
        localizations.appointmentRequestStatusAccepted,
      ),
      AppointmentRequestStatus.declined => (
        Icons.cancel_outlined,
        localizations.appointmentRequestStatusDeclined,
      ),
      AppointmentRequestStatus.requested when isAnswerable => (
        Icons.hourglass_empty_rounded,
        localizations.appointmentRequestStatusRequested,
      ),
      AppointmentRequestStatus.requested => (
        Icons.history_rounded,
        localizations.appointmentRequestStatusUnanswered,
      ),
    };
    return DSInfoChipWidget(icon: icon, label: label);
  }
}
