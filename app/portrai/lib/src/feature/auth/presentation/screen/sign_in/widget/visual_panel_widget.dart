part of 'content_widget.dart';

/// A gradient panel with a dot grid, the sign-in animation and frosted
/// highlight chips drifting around it, above the welcome copy.
class _VisualPanelWidget extends StatefulWidget {
  const _VisualPanelWidget({required this.isCompact});

  /// The shorter phone banner, without the highlight chips.
  final bool isCompact;

  @override
  State<_VisualPanelWidget> createState() => _VisualPanelWidgetState();
}

class _VisualPanelWidgetState extends State<_VisualPanelWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final isCompact = widget.isCompact;
    final accent = palette.accent.color;
    final start = Color.alphaBlend(
      accent.withAlpha(40),
      palette.surface.surfaceContainerHigh.color,
    );
    final end = Color.alphaBlend(
      accent.withAlpha(150),
      palette.surface.surfaceContainerHigh.color,
    );
    final onPanel = palette.neutral.grey10;
    final radius = context.dimen.radiusLevel3.value * 1.5;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(),
      children: [
        DSTextWidget(
          localizations.signInWelcomeTitle,
          style: isCompact
              ? context.typography.emphasizedHeadlineSmall
              : context.typography.emphasizedDisplaySmall,
          color: onPanel,
        ),
        DSTextWidget(
          localizations.signInWelcomeDescription,
          style: isCompact
              ? context.typography.bodyMedium
              : context.typography.bodyLarge,
          color: onPanel,
        ),
      ],
    );

    final illustration = AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (_floatController.value - 0.5) * 14),
        child: child,
      ),
      child: DSLottieIllustrationWidget(
        illustration: DSLottieIllustration.signIn,
        width: isCompact ? 140 : 300,
      ),
    );

    return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [start, Color.lerp(start, end, 0.5)!, end],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotGridPainter(
                      color: onPanel.color.withAlpha(28),
                    ),
                  ),
                ),
                Positioned(
                  top: -120,
                  right: -80,
                  child: _GlowWidget(size: 360, color: accent.withAlpha(120)),
                ),
                Positioned(
                  bottom: -140,
                  left: -100,
                  child: _GlowWidget(
                    size: 380,
                    color: palette.brand.primary.color.withAlpha(70),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    context.space(factor: isCompact ? 3 : 5),
                  ),
                  child: isCompact
                      ? Row(
                          children: [
                            Expanded(child: copy),
                            illustration,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _IllustrationStageWidget(
                                illustration: illustration,
                                animation: _floatController,
                                chips: [
                                  (
                                    Icons.lock_outline_rounded,
                                    localizations.signInHighlightPrivate,
                                  ),
                                  (
                                    Icons.devices_rounded,
                                    localizations.signInHighlightDevices,
                                  ),
                                  (
                                    Icons.bolt_rounded,
                                    localizations.signInHighlightStaySignedIn,
                                  ),
                                ],
                              ),
                            ),
                            copy,
                          ],
                        ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.98, 0.98),
          curve: Curves.easeOutCubic,
          duration: 600.ms,
        );
  }
}

/// The illustration in the middle with the chips placed around it, each
/// drifting at its own phase.
class _IllustrationStageWidget extends StatelessWidget {
  const _IllustrationStageWidget({
    required this.illustration,
    required this.animation,
    required this.chips,
  });

  final Widget illustration;
  final Animation<double> animation;
  final List<(IconData, String)> chips;

  // Corners of the stage, clear of the illustration in the middle.
  static const _chipAlignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomRight,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: illustration),
        for (final (chipIndex, (icon, label)) in chips.indexed)
          Align(
            alignment: _chipAlignments[chipIndex % _chipAlignments.length],
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final phase = animation.value * 2 * pi + chipIndex * 2.1;
                return Transform.translate(
                  offset: Offset(0, sin(phase) * 8),
                  child: child,
                );
              },
              child: _GlassChipWidget(icon: icon, label: label)
                  .animate()
                  .fadeIn(delay: (300 + chipIndex * 150).ms, duration: 500.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutCubic),
            ),
          ),
      ],
    );
  }
}

class _GlassChipWidget extends StatelessWidget {
  const _GlassChipWidget({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.5),
        vertical: context.space(),
      ),
      decoration: BoxDecoration(
        color: palette.surface.surface.color.withAlpha(200),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: palette.surface.surface.color),
        boxShadow: [
          BoxShadow(
            color: palette.neutral.grey10.color.withAlpha(24),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(),
        children: [
          Container(
            padding: EdgeInsets.all(context.space(factor: 0.5)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.accent.color.withAlpha(36),
            ),
            child: Icon(icon, size: 16, color: palette.accent.color),
          ),
          Flexible(
            child: DSTextWidget(
              label,
              style: context.typography.emphasizedLabelLarge,
              color: palette.neutral.grey10,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowWidget extends StatelessWidget {
  const _GlowWidget({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  static const _spacing = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = color;
    for (var y = _spacing / 2; y < size.height; y += _spacing) {
      for (var x = _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.color != color;
}
