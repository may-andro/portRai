part of 'content_widget.dart';

/// The weekly job search switch with its status, and sign-out beneath it.
class _JobSearchWidget extends StatelessWidget {
  const _JobSearchWidget({required this.state});

  final JobOpeningsState state;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: context.space(),
          children: [
            if (state.isJobSearchEnabled case final isEnabled?)
              _JobSearchCardWidget(
                isEnabled: isEnabled,
                isUpdating: state.isUpdatingJobSearch,
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
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
        )
        .animate()
        .fadeIn(delay: 150.ms, duration: 500.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}

class _JobSearchCardWidget extends StatelessWidget {
  const _JobSearchCardWidget({
    required this.isEnabled,
    required this.isUpdating,
  });

  final bool isEnabled;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final accent = palette.accent.color;
    final surface = palette.surface.surfaceContainerLow.color;
    final isMobile = context.isMobile;

    final iconBadge = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isMobile ? 48 : 64,
      height: isMobile ? 48 : 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? accent.withAlpha(40) : palette.neutral.grey3.color,
        border: Border.all(
          color: isEnabled
              ? accent.withAlpha(120)
              : palette.neutral.grey4.color,
          width: 1.5,
        ),
      ),
      child: Icon(
        isEnabled ? Icons.radar_rounded : Icons.pause_rounded,
        size: isMobile ? 24 : 30,
        color: isEnabled ? accent : palette.neutral.grey7.color,
      ),
    );
    final title = DSTextWidget(
      localizations.jobSearchToggleTitle,
      style: isMobile
          ? context.typography.emphasizedTitleMedium
          : context.typography.emphasizedTitleLarge,
      color: palette.neutral.grey10,
    );
    final toggle = Switch(
      value: isEnabled,
      onChanged: isUpdating
          ? null
          : (isEnabled) => context.bloc.add(
              JobSearchToggleClickEvent(isEnabled: isEnabled),
            ),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        _StatusPillWidget(isEnabled: isEnabled),
        DSTextWidget(
          localizations.jobSearchToggleDescription,
          style: context.typography.bodyMedium,
          color: palette.neutral.grey7,
        ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(context.space(factor: isMobile ? 2 : 3)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surface,
            Color.alphaBlend(accent.withAlpha(isEnabled ? 36 : 10), surface),
          ],
        ),
        border: Border.all(
          color: isEnabled
              ? accent.withAlpha(80)
              : palette.outline.outlineVariant.color,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 1.5),
              children: [
                Row(
                  spacing: context.space(factor: 1.5),
                  children: [
                    iconBadge,
                    Expanded(child: title),
                    toggle,
                  ],
                ),
                details,
              ],
            )
          : Row(
              spacing: context.space(factor: 2.5),
              children: [
                iconBadge,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(),
                    children: [title, details],
                  ),
                ),
                Transform.scale(scale: 1.15, child: toggle),
              ],
            ),
    );
  }
}

class _StatusPillWidget extends StatelessWidget {
  const _StatusPillWidget({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final color = isEnabled
        ? palette.semantic.success.color
        : palette.neutral.grey7.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.25),
        vertical: context.space(factor: 0.5),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.75),
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          Flexible(
            child: DSTextWidget(
              isEnabled
                  ? context.localizations.jobSearchStatusActive
                  : context.localizations.jobSearchStatusPaused,
              style: context.typography.emphasizedLabelLarge,
              color: isEnabled
                  ? palette.semantic.success
                  : palette.neutral.grey7,
            ),
          ),
        ],
      ),
    );
  }
}
