part of 'content_widget.dart';

/// One design system as a playing card, drawn in its own colors, shapes and
/// fonts: the month in the corner, the festival effect across the face, and
/// the name, a line about it and its main colors at the bottom.
class _ThemeCardWidget extends StatelessWidget {
  const _ThemeCardWidget({
    required this.designSystem,
    required this.month,
    required this.isMonthly,
    required this.isApplied,
    required this.isAnimated,
  });

  final DesignSystem designSystem;

  /// From 1 to 12.
  final int month;
  final bool isMonthly;
  final bool isApplied;

  /// Runs the festival effect; cards deep in the deck stay still.
  final bool isAnimated;

  /// The card is laid out at this phone-sized layout and scaled to the space
  /// it gets, so it looks the same on every screen.
  static const _layoutSize = Size(272, 400);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox.fromSize(
        size: _layoutSize,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(size: _layoutSize),
          child: DSThemeBuilderWidget(
            designSystem: designSystem,
            brightness: context.platformBrightness,
            child: Builder(builder: _buildCard),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final palette = context.colorPalette;
    final brand = palette.brand;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    final padding = context.space(factor: 2);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand.primary.color, brand.tertiary.color],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.utility.shadow.color.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isAnimated)
              const DSFestiveBackdropWidget(
                shape: DSFestiveBackdropShape.rectangle,
                particleCount: 36,
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.3, 0.5, 1],
                  colors: [
                    palette.utility.scrim.color.withValues(alpha: 0.3),
                    palette.neutral.transparent.color,
                    palette.neutral.transparent.color,
                    palette.utility.scrim.color.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CornerIndexWidget(month: month),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: context.space(factor: 0.5),
                        children: [
                          if (isApplied)
                            _BadgeWidget(
                              label: context.localizations.themeGalleryInUse,
                              icon: Icons.check_rounded,
                            ),
                          if (isMonthly)
                            _BadgeWidget(
                              label:
                                  context.localizations.themeGalleryThisMonth,
                              icon: Icons.event_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  DSTextWidget(
                    designSystem.title(context),
                    style: context.typography.emphasizedDisplaySmall,
                    color: _lightestNeutral(context),
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  const DSVerticalSpacerWidget(0.5),
                  DSTextWidget(
                    designSystem.tagline(context),
                    style: context.typography.bodyMedium,
                    color: _lightestNeutral(context),
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  const DSVerticalSpacerWidget(1.5),
                  _SwatchesWidget(
                    colors: [
                      brand.primary,
                      brand.secondary,
                      brand.tertiary,
                      palette.background,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text on a card sits on a darkened face, so it uses the lightest neutral,
/// which dark palettes keep in `black`.
DSColor _lightestNeutral(BuildContext context) => context.isDarkMode
    ? context.colorPalette.neutral.black
    : context.colorPalette.neutral.white;

/// The month number over the short month name, like a card's rank.
class _CornerIndexWidget extends StatelessWidget {
  const _CornerIndexWidget({required this.month});

  final int month;

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat.MMM(
      Localizations.localeOf(context).toString(),
    ).format(DateTime(2000, month));
    return Column(
      children: [
        DSTextWidget(
          '$month',
          style: context.typography.emphasizedHeadlineMedium,
          color: _lightestNeutral(context),
        ),
        DSTextWidget(
          monthName.toUpperCase(),
          style: context.typography.emphasizedLabelSmall,
          color: _lightestNeutral(context),
        ),
      ],
    );
  }
}

class _BadgeWidget extends StatelessWidget {
  const _BadgeWidget({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final white = _lightestNeutral(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: white.color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(context.dimen.radiusCircular.value),
        border: Border.all(color: white.color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(),
          vertical: context.space(factor: 0.25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 0.5),
          children: [
            DSIconWidget(icon, color: white, size: DSIconSize.small),
            DSTextWidget(
              label,
              style: context.typography.emphasizedLabelSmall,
              color: white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlapping dots of the design system's main colors.
class _SwatchesWidget extends StatelessWidget {
  const _SwatchesWidget({required this.colors});

  final List<DSColor> colors;

  @override
  Widget build(BuildContext context) {
    final dotSize = context.space(factor: 3);
    return Row(
      children: [
        for (final color in colors)
          Align(
            widthFactor: 0.7,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: color.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _lightestNeutral(context).color,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
