part of 'content_widget.dart';

class _IntroWidget extends StatelessWidget {
  const _IntroWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final isMobile = context.isMobile;
    final highlights = [
      (Icons.lock_outline_rounded, localizations.signInHighlightPrivate),
      (Icons.devices_rounded, localizations.signInHighlightDevices),
      (Icons.verified_user_outlined, localizations.signInHighlightSecure),
    ];

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: isMobile ? 1.5 : 2),
          children: [
            Container(
              width: context.space(factor: 5),
              height: 4,
              decoration: BoxDecoration(
                color: palette.accent.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            DSTextWidget(
              localizations.signInWelcomeTitle,
              style: isMobile
                  ? context.typography.emphasizedHeadlineLarge
                  : context.typography.emphasizedDisplayMedium,
              color: palette.neutral.grey10,
            ),
            DSTextWidget(
              localizations.signInWelcomeDescription,
              style: context.typography.bodyLarge,
              color: palette.neutral.grey8,
            ),
            if (!isMobile)
              Padding(
                padding: EdgeInsets.only(top: context.space()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.space(factor: 1.5),
                  children: [
                    for (final (icon, label) in highlights)
                      _HighlightWidget(icon: icon, label: label),
                  ],
                ),
              ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.04, curve: Curves.easeOutCubic);
  }
}

class _HighlightWidget extends StatelessWidget {
  const _HighlightWidget({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    return Row(
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
          child: Icon(icon, size: 22, color: accent),
        ),
        Flexible(
          child: DSTextWidget(
            label,
            style: context.typography.emphasizedBodyLarge,
            color: palette.neutral.grey9,
          ),
        ),
      ],
    );
  }
}
