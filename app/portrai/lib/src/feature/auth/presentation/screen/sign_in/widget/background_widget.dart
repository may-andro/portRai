part of 'content_widget.dart';

/// Drifting shapes and two soft rings behind the sign-in content.
class _BackgroundWidget extends StatefulWidget {
  const _BackgroundWidget();

  @override
  State<_BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<_BackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final ringSize = context.isMobile ? 320.0 : 560.0;

    return ColoredBox(
      color: palette.background.color,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final drift = (_controller.value - 0.5) * 28;
            return Stack(
              fit: StackFit.expand,
              children: [
                DSFloatingShapesBackgroundWidget(color: accent.withAlpha(60)),
                Positioned(
                  right: -ringSize * 0.25,
                  top: -ringSize * 0.2,
                  child: Transform.translate(
                    offset: Offset(-drift * 0.5, drift * 0.4),
                    child: _RingWidget(
                      size: ringSize,
                      color: accent.withAlpha(50),
                    ),
                  ),
                ),
                Positioned(
                  left: -ringSize * 0.3,
                  bottom: -ringSize * 0.35,
                  child: Transform.translate(
                    offset: Offset(drift * 0.4, -drift * 0.3),
                    child: _RingWidget(
                      size: ringSize * 0.8,
                      color: palette.brand.primary.color.withAlpha(45),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RingWidget extends StatelessWidget {
  const _RingWidget({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }
}
