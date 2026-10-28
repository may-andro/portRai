part of 'content_widget.dart';

/// Confirms an answer. Pops with `true` when the owner confirms.
class _DecisionDialogWidget extends StatelessWidget {
  const _DecisionDialogWidget({required this.name, required this.decision});

  final String name;
  final AppointmentDecision decision;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final (title, description, confirmLabel) = switch (decision) {
      AppointmentDecision.accept => (
        localizations.appointmentRequestAcceptTitle,
        localizations.appointmentRequestAcceptDescription(name),
        localizations.appointmentRequestAccept,
      ),
      AppointmentDecision.decline => (
        localizations.appointmentRequestDeclineTitle,
        localizations.appointmentRequestDeclineDescription(name),
        localizations.appointmentRequestDecline,
      ),
    };

    return DSDialogWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 2),
        children: [
          DSTextWidget(
            title,
            style: context.typography.emphasizedTitleLarge,
            color: palette.neutral.grey9,
          ),
          DSTextWidget(
            description,
            style: context.typography.bodyMedium,
            color: palette.neutral.grey8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: context.space(),
            children: [
              DSButtonWidget(
                label: localizations.appointmentRequestCancel,
                variant: DSButtonVariant.text,
                size: DSButtonSize.small,
                isExpanded: false,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              DSButtonWidget(
                label: confirmLabel,
                size: DSButtonSize.small,
                isExpanded: false,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
