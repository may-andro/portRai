part of 'content_widget.dart';

class _FormWidget extends StatefulWidget {
  const _FormWidget({required this.isCompact, required this.topic});

  /// A shorter message field, so the whole form fits on a desktop screen.
  final bool isCompact;

  /// What the appointment is about, given by the host such as a service page, or
  /// empty.
  final String topic;

  @override
  State<_FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<_FormWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  var _hasAcceptedPrivacyPolicy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    context.bloc.add(
      SendAppointmentRequestClickEvent(
        label: 'send_appointment_request_button',
        name: _nameController.text,
        email: _emailController.text,
        // The form does not ask for a topic: the host's, such as a service
        // title, or a general one.
        topic: widget.topic.isNotEmpty
            ? widget.topic
            : context.localizations.scheduleAppointmentDefaultTopic,
        message: _messageController.text,
        hasAcceptedPrivacyPolicy: _hasAcceptedPrivacyPolicy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final borderColor = palette.neutral.grey4;

    return BlocBuilder<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedSlot != current.selectedSlot,
      builder: (context, state) {
        final isSending = state.status == ScheduleAppointmentStatus.sending;
        final hasSlot = state.selectedSlot != null;
        final name = DSTextFieldWidget(
          controller: _nameController,
          labelText: localizations.scheduleAppointmentNameLabel,
          autofillHints: const [AutofillHints.name],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 100,
          enabledBorderColor: borderColor,
          enabled: !isSending,
        );
        final email = DSTextFieldWidget(
          controller: _emailController,
          labelText: localizations.scheduleAppointmentEmailLabel,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          maxLength: 254,
          enabledBorderColor: borderColor,
          enabled: !isSending,
        );
        final sendButton = DSButtonWidget(
          label: localizations.scheduleAppointmentSend,
          isLoading: isSending,
          isDisabled: !hasSlot || isSending,
          onPressed: _send,
        );
        return AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _formRowSpacing(context),
            children: [
              name,
              email,
              DSTextFieldWidget(
                controller: _messageController,
                labelText: localizations.scheduleAppointmentMessageLabel,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: widget.isCompact ? 3 : 4,
                maxLength: 2000,
                enabledBorderColor: borderColor,
                enabled: !isSending,
              ),
              _ConsentWidget(
                hasAccepted: _hasAcceptedPrivacyPolicy,
                isEnabled: !isSending,
                onChanged: (hasAccepted) =>
                    setState(() => _hasAcceptedPrivacyPolicy = hasAccepted),
              ),
              sendButton,
            ],
          ),
        );
      },
    );
  }
}

class _ConsentWidget extends StatelessWidget {
  const _ConsentWidget({
    required this.hasAccepted,
    required this.isEnabled,
    required this.onChanged,
  });

  final bool hasAccepted;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    // The box lines up with the fields' left edge and the first line of text.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.5),
      children: [
        SizedBox.square(
          dimension: 24,
          child: Checkbox(
            value: hasAccepted,
            activeColor: palette.accent.color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onChanged: isEnabled
                ? (hasAccepted) => onChanged(hasAccepted ?? false)
                : null,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 0.5),
            children: [
              GestureDetector(
                onTap: isEnabled ? () => onChanged(!hasAccepted) : null,
                child: DSTextWidget(
                  localizations.scheduleAppointmentConsent,
                  style: context.typography.bodyMedium,
                  color: palette.neutral.grey9,
                ),
              ),
              InkWell(
                onTap: () => context.bloc.add(
                  const PrivacyPolicyClickEvent('privacy_policy_link'),
                ),
                child: DSTextWidget(
                  localizations.scheduleAppointmentPrivacyPolicyLink,
                  style: context.typography.emphasizedLabelLarge,
                  color: palette.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
