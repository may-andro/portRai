part of 'footer_widget.dart';

const _buttonSize = DSButtonSize.small;

class _ContactWidget extends StatelessWidget {
  const _ContactWidget();

  @override
  Widget build(BuildContext context) {
    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    final resumeUrl = state.profile.resume.url;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        DSTextWidget(
          context.localizations.footerContactTitle,
          style: context.typography.emphasizedTitleMedium,
          color: context.colorPalette.onInverseSurface,
        ),
        Row(
          spacing: context.space(factor: 2),
          mainAxisSize: MainAxisSize.min,
          children: [
            DSButtonWidget(
              label: context.localizations.downloadResume,
              onPressed: () {
                context.bloc.add(
                  OpenExternalUrlEvent(label: 'Resume', url: resumeUrl),
                );
              },
              icon: Icons.file_present_rounded,
              iconDirection: DSButtonIconDirection.right,
              size: _buttonSize,
            ),
            DSButtonWidget(
              label: context.localizations.contactMe,
              onPressed: () {
                context.bloc.add(OpenEmailClientEvent(state.profile.email));
              },
              icon: Icons.email_rounded,
              iconDirection: DSButtonIconDirection.right,
              size: _buttonSize,
            ),
          ],
        ),
      ],
    );
  }
}
