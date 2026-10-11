part of 'content_widget.dart';

class _ConsentWidget extends StatelessWidget {
  const _ConsentWidget({required this.isBusy, this.errorText});

  final bool isBusy;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: EdgeInsets.all(context.space(factor: 3)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_outlined, size: 48),
                const DSVerticalSpacerWidget(2),
                Text(
                  localizations.remoteAssistantTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const DSVerticalSpacerWidget(2),
                Text(
                  localizations.remoteAssistantDisclosure,
                  textAlign: TextAlign.center,
                ),
                const DSVerticalSpacerWidget(2),
                if (errorText case final text?) ...[
                  Text(
                    text,
                    style: TextStyle(
                      color: context.colorPalette.semantic.error.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const DSVerticalSpacerWidget(1),
                ],
                FilledButton(
                  onPressed: isBusy
                      ? null
                      : () => context.bloc.add(
                          const AcceptRemoteAssistantConsentClickEvent(),
                        ),
                  child: Text(localizations.remoteAssistantAcceptConsent),
                ),
                if (isBusy) ...[
                  const DSVerticalSpacerWidget(1),
                  const DSLoadingWidget(size: 28),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
