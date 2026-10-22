part of 'content_widget.dart';

/// Widest the welcome copy grows in the side-by-side panel.
const _copyMaxWidth = 480.0;

/// The welcome panel: a deep gradient with translucent waves rolling across
/// its lower part, the welcome copy and the floating sign-in animation.
class _VisualPanelWidget extends StatefulWidget {
  const _VisualPanelWidget({required this.isCompact, this.topInset = 0});

  /// The shorter band above the form on phones and tablets.
  final bool isCompact;

  /// Space kept free at the top for the header laid over the band.
  final double topInset;

  @override
  State<_VisualPanelWidget> createState() => _VisualPanelWidgetState();
}

class _VisualPanelWidgetState extends State<_VisualPanelWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final isCompact = widget.isCompact;
    final accent = palette.accent.color;
    // A deep panel in both themes: the dark surface in dark mode, the
    // inverse (dark) surface in light mode.
    final isDarkTheme = palette.background.color.computeLuminance() < 0.5;
    final base = isDarkTheme
        ? palette.surface.surfaceContainerLow.color
        : palette.surface.inverseSurface.color;
    final onPanel = isDarkTheme
        ? palette.neutral.grey10
        : palette.surface.onInverseSurface;

    final copy =
        Column(
              crossAxisAlignment: isCompact
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: context.space(),
              children: [
                Container(
                  width: context.space(factor: 5),
                  height: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                DSTextWidget(
                  localizations.signInWelcomeTitle,
                  style: isCompact
                      ? context.typography.emphasizedHeadlineMedium
                      : context.typography.emphasizedDisplayMedium,
                  color: onPanel,
                  textAlign: isCompact ? TextAlign.start : TextAlign.center,
                ),
                DSTextWidget(
                  localizations.signInWelcomeDescription,
                  style: context.typography.bodyLarge,
                  color: onPanel,
                  textAlign: isCompact ? TextAlign.start : TextAlign.center,
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic);

    final illustration = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, sin(_controller.value * 2 * pi) * 8),
        child: child,
      ),
      child: DSLottieIllustrationWidget(
        illustration: DSLottieIllustration.signIn,
        width: isCompact ? 140 : 380,
      ),
    );

    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [base, Color.alphaBlend(accent.withAlpha(70), base)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _WavesPainter(
                    animation: _controller,
                    colors: [
                      accent.withAlpha(45),
                      accent.withAlpha(75),
                      accent.withAlpha(120),
                    ],
                  ),
                ),
              ),
            ),
            if (isCompact)
              Padding(
                // The band starts where the logo does, below the header.
                padding: EdgeInsets.fromLTRB(
                  PageHeaderWidget.horizontalPadding(context),
                  widget.topInset + context.space(factor: 2),
                  PageHeaderWidget.horizontalPadding(context),
                  context.space(factor: 4),
                ),
                child: Row(
                  spacing: context.space(factor: 2),
                  children: [
                    Expanded(child: copy),
                    illustration,
                  ],
                ),
              )
            else
              // Centred in the panel, below the logo header.
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 7),
                  vertical: context.space(factor: 8),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _copyMaxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: context.space(factor: 4),
                      children: [
                        // Shrinks on short windows so the copy always fits.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: illustration,
                          ),
                        ),
                        copy,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Three translucent sine waves filling the lower part of the panel, each
/// rolling sideways at its own speed.
class _WavesPainter extends CustomPainter {
  _WavesPainter({required this.animation, required this.colors})
    : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (waveIndex, color) in colors.indexed) {
      final phase = animation.value * 2 * pi * (waveIndex + 1);
      final baseline = size.height * (0.62 + waveIndex * 0.1);
      final amplitude = size.height * (0.04 - waveIndex * 0.008);
      final wavelength = size.width * (1.1 - waveIndex * 0.2);
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width; x += 4) {
        final y = baseline + sin(x / wavelength * 2 * pi + phase) * amplitude;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_WavesPainter oldDelegate) => oldDelegate.colors != colors;
}
