part of 'content_widget.dart';

/// A full-bleed gradient panel with a dot grid and the floating sign-in
/// animation above the welcome copy.
class _VisualPanelWidget extends StatefulWidget {
  const _VisualPanelWidget({required this.isCompact});

  /// The shorter band for phones and tablets.
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
    final base = palette.surface.surfaceContainerHigh.color;
    final start = Color.alphaBlend(accent.withAlpha(40), base);
    final end = Color.alphaBlend(accent.withAlpha(150), base);
    final onPanel = palette.neutral.grey10;

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
        width: isCompact ? 150 : 380,
      ),
    );

    return ClipRect(
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
                painter: _DotGridPainter(color: onPanel.color.withAlpha(28)),
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
              padding: EdgeInsets.symmetric(
                horizontal: isCompact
                    ? context.space(factor: 3)
                    : context.space(factor: 6),
                vertical: context.space(factor: isCompact ? 4 : 6),
              ),
              child: isCompact
                  ? Row(
                      spacing: context.space(factor: 2),
                      children: [
                        Expanded(child: copy),
                        illustration,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Center(child: illustration)),
                        copy,
                      ],
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
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
