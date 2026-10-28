part of 'content_widget.dart';

/// The eyebrow, the title and where the times are shown.
class _HeroCopyWidget extends StatelessWidget {
  const _HeroCopyWidget({required this.isLarge});

  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 1.5),
      children: [
        PageEyebrowWidget(localizations.bookCallTitle, onDark: true),
        DSTextWidget(
          localizations.bookCallHeroTitle,
          style: isLarge
              ? context.typography.emphasizedDisplaySmall
              : context.typography.emphasizedHeadlineMedium,
          color: pageOnDarkColor,
        ),
        DSTextWidget(
          localizations.bookCallDescription(DateTime.now().timeZoneName),
          style: context.typography.bodyLarge,
          color: pageOnDarkColor,
        ),
      ],
    );
  }
}

/// The still backdrop of the header and the desktop panel: a deep base with
/// soft glows of the brand colours, like an aurora, and a fine dot grid.
class _AuroraBackdropWidget extends StatelessWidget {
  const _AuroraBackdropWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final base = Color.lerp(palette.brand.primary.color, Colors.black, 0.82)!;
    Widget glow(Alignment center, Color color, double radius) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color.withAlpha(150), color.withAlpha(0)],
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: base),
        glow(const Alignment(0.9, -0.9), palette.brand.primary.color, 1.1),
        glow(const Alignment(-1, 0.6), palette.brand.tertiary.color, 1),
        glow(const Alignment(0.3, 1.1), palette.accent.color, 0.8),
        const CustomPaint(painter: _DotGridPainter()),
      ],
    );
  }
}

/// Faint dots on a regular grid, for texture.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  static const _gap = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(22);
    for (var y = _gap / 2; y < size.height; y += _gap) {
      for (var x = _gap / 2; x < size.width; x += _gap) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}

/// The header on phones and tablets: the copy below the calendar scene, with
/// the logo chrome on top.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget();

  @override
  Widget build(BuildContext context) {
    return DSOffscreenPauseWidget(
      child: ClipRect(
        child: Stack(
          children: [
            const Positioned.fill(child: _AuroraBackdropWidget()),
            PageChromeWidget(
              closeColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.screenHorizontalPadding.left,
                  context.space(),
                  context.screenHorizontalPadding.left,
                  context.space(factor: 3),
                ),
                // As wide as the form below, so the copy lines up with it.
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _contentMaxWidth,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) => Column(
                        spacing: context.space(factor: 2),
                        children: [
                          _FloatingSceneWidget(
                            width: min(constraints.maxWidth, 480),
                          ),
                          const _HeroCopyWidget(isLarge: false),
                        ],
                      ),
                    ),
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

/// Widest the copy grows in the desktop panel.
const _panelCopyMaxWidth = 480.0;

/// The narrowest the panel's copy is before its title shrinks to a headline.
const _largeCopyMinWidth = 360.0;

/// The decorative desktop panel beside the cards. It runs the full height of
/// the page, and its scene and copy stay in view while the cards scroll.
class _VisualPanelWidget extends StatelessWidget {
  const _VisualPanelWidget({required this.topInset});

  /// Space kept free at the top for the header laid over the panel.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        // Narrow panels keep less space at the sides, so the scene and the
        // copy keep their room.
        final sidePadding = (constraints.maxWidth * 0.1).clamp(
          context.space(factor: 2),
          context.space(factor: 7),
        );
        final copyWidth = min(
          constraints.maxWidth - 2 * sidePadding,
          _panelCopyMaxWidth,
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(
            sidePadding,
            topInset + context.space(factor: 3),
            sidePadding,
            context.space(factor: 6),
          ),
          child: Center(
            child: SizedBox(
              width: copyWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(factor: 4),
                children: [
                  // Shrinks on short windows so the copy always fits.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _FloatingSceneWidget(width: copyWidth),
                    ),
                  ),
                  _HeroCopyWidget(isLarge: copyWidth >= _largeCopyMinWidth)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        );
      },
    );

    return DSOffscreenPauseWidget(
      child: ClipRect(
        child: Stack(
          children: [
            const Positioned.fill(child: _AuroraBackdropWidget()),
            _StickyViewportWidget(child: content),
          ],
        ),
      ),
    );
  }
}

/// Keeps [child] one viewport tall and moves it down with the scroll, so it
/// stays in view until the end of its parent.
class _StickyViewportWidget extends StatelessWidget {
  const _StickyViewportWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = min(
          position?.hasViewportDimension ?? false
              ? position!.viewportDimension
              : MediaQuery.sizeOf(context).height,
          constraints.maxHeight,
        );
        final maxOffset = max(0.0, constraints.maxHeight - viewportHeight);
        final sized = SizedBox(height: viewportHeight, child: child);
        if (position == null) return sized;
        return AnimatedBuilder(
          animation: position,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, position.pixels.clamp(0.0, maxOffset)),
            child: child,
          ),
          child: sized,
        );
      },
    );
  }
}

/// The calendar scene, drifting gently up and down, faded out at the bottom.
class _FloatingSceneWidget extends StatefulWidget {
  const _FloatingSceneWidget({required this.width});

  final double width;

  @override
  State<_FloatingSceneWidget> createState() => _FloatingSceneWidgetState();
}

class _FloatingSceneWidgetState extends State<_FloatingSceneWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, sin(_controller.value * 2 * pi) * 6),
        child: child,
      ),
      // The figure ends in a straight line at the waist; fading the bottom
      // blends it into the backdrop.
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.72, 0.9],
        ).createShader(bounds),
        child: DSLottieIllustrationWidget(
          illustration: DSLottieIllustration.calendarBooking,
          width: widget.width,
        ),
      ),
    );
  }
}
