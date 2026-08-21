part of 'footer_widget.dart';

class _HelpWidget extends StatelessWidget {
  const _HelpWidget();

  @override
  Widget build(BuildContext context) {
    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    final termsAndConditionsUrl = state.profile.resume.url;
    final privacyPolicyUrl = state.profile.resume.url;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        DSTextWidget(
          context.localizations.help,
          color: context.colorPalette.onInverseSurface,
          style: context.typography.emphasizedTitleMedium,
        ),
        if (termsAndConditionsUrl.isNotNullOrEmpty)
          _LinkWidget(
            label: context.localizations.termsAndConditions,
            onTap: () {
              context.bloc.add(
                OpenExternalUrlEvent(
                  label: 'Terms and Conditions',
                  url: termsAndConditionsUrl,
                ),
              );
            },
          ),
        if (privacyPolicyUrl.isNotNullOrEmpty)
          _LinkWidget(
            label: context.localizations.privacyPolicy,
            onTap: () {
              context.bloc.add(
                OpenExternalUrlEvent(
                  label: 'Privacy Policy',
                  url: privacyPolicyUrl,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _LinkWidget extends StatelessWidget {
  const _LinkWidget({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DSTextWidget(
        label,
        style: context.typography.titleSmall,
        color: context.colorPalette.surface.onInverseSurface,
      ),
    );
  }
}
