import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/_bloc.dart';

/// Shows the logo at the size and position the native splash draws it, so
/// the hand over from the native splash doesn't move the logo. Once set up
/// completes, a circle in the app's surface color grows out of the logo
/// while the logo fades, leaving the background the app opens on.
class CircularRevealLogoWidget extends StatefulWidget {
  const CircularRevealLogoWidget({
    super.key,
    required this.state,
    required this.onComplete,
  });

  /// The native splash draws the logo artwork 172.5 logical pixels wide,
  /// and the artwork fills 78% of the logo image.
  static const double logoSize = 221.6;

  final SplashState state;
  final VoidCallback onComplete;

  @override
  State<CircularRevealLogoWidget> createState() =>
      _CircularRevealLogoWidgetState();
}

class _CircularRevealLogoWidgetState extends State<CircularRevealLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController revealController = AnimationController(
    duration: 600.milliseconds,
    vsync: this,
  )..addStatusListener(_onRevealStatusChanged);

  @override
  void initState() {
    super.initState();
    _revealWhenSetUpCompleted();
  }

  @override
  void didUpdateWidget(covariant CircularRevealLogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _revealWhenSetUpCompleted();
  }

  void _revealWhenSetUpCompleted() {
    if (widget.state is SetUpCompetedState && revealController.isDismissed) {
      revealController.forward();
    }
  }

  void _onRevealStatusChanged(AnimationStatus status) {
    if (status.isCompleted) widget.onComplete();
  }

  Color _appSurfaceColor(DesignSystem designSystem) {
    return DSTheme(
      brightness: context.platformBrightness,
      designSystem: designSystem,
    ).colorPalette.surface.surface.color;
  }

  @override
  void dispose() {
    revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return AnimatedBuilder(
      animation: revealController,
      builder: (context, logo) {
        final revealProgress = Curves.easeOut.transform(revealController.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (state is SetUpCompetedState)
              CustomPaint(
                painter: _CircularRevealPainter(
                  color: _appSurfaceColor(state.designSystem),
                  progress: revealProgress,
                ),
              ),
            Center(
              child: Opacity(opacity: 1 - revealProgress, child: logo),
            ),
          ],
        );
      },
      child: SizedBox.square(
        dimension: CircularRevealLogoWidget.logoSize,
        child: DSImage.logo(),
      ),
    );
  }
}

class _CircularRevealPainter extends CustomPainter {
  const _CircularRevealPainter({required this.color, required this.progress});

  final Color color;

  /// 0 draws nothing, 1 covers the whole canvas.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final coveringRadius =
        sqrt(size.width * size.width + size.height * size.height) / 2;
    canvas.drawCircle(
      size.center(Offset.zero),
      coveringRadius * progress,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularRevealPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
