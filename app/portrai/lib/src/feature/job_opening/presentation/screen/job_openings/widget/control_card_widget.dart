part of 'content_widget.dart';

/// The weekly job search switch and sign-out, in a frosted card.
class _ControlCardWidget extends StatelessWidget {
  const _ControlCardWidget({required this.state});

  final JobOpeningsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final accent = palette.accent.color;
    final isJobSearchEnabled = state.isJobSearchEnabled;

    return Container(
          padding: EdgeInsets.all(context.space(factor: 2.5)),
          decoration: BoxDecoration(
            color: palette.surface.surfaceContainerLow.color.withAlpha(235),
            borderRadius: BorderRadius.circular(
              context.dimen.radiusLevel3.value,
            ),
            border: Border.all(color: accent.withAlpha(60)),
            boxShadow: [BoxShadow(color: accent.withAlpha(20), blurRadius: 40)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: context.space(factor: 2),
            children: [
              if (isJobSearchEnabled != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.space(factor: 1.5),
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.space()),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(36),
                        borderRadius: BorderRadius.circular(
                          context.dimen.radiusLevel1.value,
                        ),
                      ),
                      child: Icon(
                        isJobSearchEnabled
                            ? Icons.radar_rounded
                            : Icons.pause_circle_outline_rounded,
                        size: 22,
                        color: accent,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: context.space(factor: 0.5),
                        children: [
                          DSTextWidget(
                            localizations.jobSearchToggleTitle,
                            style: context.typography.emphasizedTitleMedium,
                            color: palette.neutral.grey10,
                          ),
                          DSTextWidget(
                            localizations.jobSearchToggleDescription,
                            style: context.typography.bodyMedium,
                            color: palette.neutral.grey7,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isJobSearchEnabled,
                      onChanged: state.isUpdatingJobSearch
                          ? null
                          : (isEnabled) => context.bloc.add(
                              JobSearchToggleClickEvent(isEnabled: isEnabled),
                            ),
                    ),
                  ],
                ),
              if (isJobSearchEnabled != null)
                Divider(height: 1, color: palette.outline.outlineVariant.color),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: DSButtonWidget(
                  label: localizations.signOutButton,
                  icon: Icons.logout_rounded,
                  variant: DSButtonVariant.text,
                  size: DSButtonSize.small,
                  isExpanded: false,
                  isLoading: state.isSigningOut,
                  isDisabled: state.isSigningOut || state.isSignedOut,
                  onPressed: () => context.bloc.add(const SignOutClickEvent()),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 150.ms, duration: 500.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}
