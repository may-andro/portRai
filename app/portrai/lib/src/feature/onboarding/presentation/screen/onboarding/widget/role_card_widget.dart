part of 'content_widget.dart';

class _RoleCardWidget extends StatelessWidget {
  const _RoleCardWidget({
    required this.role,
    required this.index,
    required this.isSelected,
    required this.isDisabled,
  });

  final UserRole role;
  final int index;
  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final accent = role.accent(context);
    final isDimmed = isDisabled && !isSelected;

    return Semantics(
          button: true,
          enabled: !isDisabled,
          label: role.title(context),
          hint: role.description(context),
          excludeSemantics: true,
          child: AnimatedOpacity(
            opacity: isDimmed ? 0.4 : 1,
            duration: const Duration(milliseconds: 250),
            child: DSSpotlightCardWidget(
              glowColor: accent,
              background: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: ColoredBox(
                  color: context.colorPalette.surface.surfaceContainer.color
                      .withAlpha(90),
                ),
              ),
              fillColor: context.colorPalette.surface.onSurface,
              padding: EdgeInsets.all(context.space(factor: 2)),
              onTap: isDisabled
                  ? null
                  : () => context.bloc.add(RoleSelectedClickEvent(role)),
              builder: (context, isHovering) {
                final illustration = _IllustrationWidget(
                  role: role,
                  isHovering: isHovering,
                );
                final texts = _TextsWidget(role: role);
                final trailing = _ArrowWidget(
                  accent: accent,
                  isHovering: isHovering,
                  isLoading: isSelected,
                );

                if (context.isMobile) {
                  return Row(
                    spacing: context.space(factor: 2),
                    children: [
                      illustration,
                      Expanded(child: texts),
                      trailing,
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.space(factor: 2),
                  children: [
                    Center(child: illustration),
                    Expanded(child: texts),
                    Align(alignment: Alignment.centerRight, child: trailing),
                  ],
                );
              },
            ),
          ),
        )
        .animate(delay: (200 + index * 120).ms)
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _IllustrationWidget extends StatelessWidget {
  const _IllustrationWidget({required this.role, required this.isHovering});

  final UserRole role;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final isReducedMotion = MediaQuery.disableAnimationsOf(context);

    return ExcludeSemantics(
      child: AnimatedScale(
        scale: isHovering ? 1.06 : 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: DSLottieIllustrationWidget(
          illustration: role.illustration,
          width: context.isMobile ? 104 : 190,
          playback: isReducedMotion
              ? DSLottiePlayback.once
              : DSLottiePlayback.loop,
        ),
      ),
    );
  }
}

class _TextsWidget extends StatelessWidget {
  const _TextsWidget({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.5),
      children: [
        DSTextWidget(
          role.title(context),
          style: context.typography.emphasizedTitleLarge,
          color: context.colorPalette.surface.onSurface,
        ),
        DSTextWidget(
          role.description(context),
          style: context.typography.bodyMedium,
          color: context.colorPalette.surface.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _ArrowWidget extends StatelessWidget {
  const _ArrowWidget({
    required this.accent,
    required this.isHovering,
    required this.isLoading,
  });

  final DSColor accent;
  final bool isHovering;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return DSLoadingWidget(size: context.space(factor: 2.5));
    }
    return AnimatedSlide(
      offset: Offset(isHovering ? 0.3 : 0, 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: DSIconWidget(
        Icons.arrow_forward_rounded,
        color: accent,
        size: DSIconSize.medium,
      ),
    );
  }
}
