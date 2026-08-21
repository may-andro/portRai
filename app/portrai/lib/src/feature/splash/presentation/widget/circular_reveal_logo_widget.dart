import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/_bloc.dart';

class CircularRevealLogoWidget extends StatefulWidget {
  const CircularRevealLogoWidget({
    super.key,
    required this.state,
    required this.constraints,
    required this.onComplete,
  });

  final SplashState state;
  final BoxConstraints constraints;
  final VoidCallback onComplete;

  @override
  State<CircularRevealLogoWidget> createState() =>
      _CircularRevealLogoWidgetState();
}

class _CircularRevealLogoWidgetState extends State<CircularRevealLogoWidget>
    with TickerProviderStateMixin {
  final double logoMoveOffsetRatio = 0.0;
  final double logoFinalScale = 0.75;

  late AnimationController moveController;
  late AnimationController scaleController;
  late Animation<double> moveYAnimation;
  late Animation<double> scaleAnimation;

  bool hasCompletedMoveAnimation = false;
  bool hasCompletedScaleAnimation = false;

  double get _logoSizeRatio => context.isDesktop ? 0.15 : 0.3;

  @override
  void initState() {
    super.initState();
    initializeAnimationControllers();
    startSequentialAnimations();
  }

  void initializeAnimationControllers() {
    moveController = AnimationController(
      duration: 300.milliseconds,
      vsync: this,
    );

    scaleController = AnimationController(
      duration: 300.milliseconds,
      vsync: this,
    );

    moveYAnimation = Tween<double>(
      begin: 0,
      end: -_calculateVerticalMoveOffset(),
    ).animate(CurvedAnimation(parent: moveController, curve: Curves.easeInOut));

    scaleAnimation = Tween<double>(begin: 1.0, end: logoFinalScale).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
    );
  }

  void startSequentialAnimations() {
    if (!hasCompletedMoveAnimation) {
      hasCompletedMoveAnimation = true;
      moveController.forward().then((_) => _onMoveAnimationComplete());
    }
  }

  void _onMoveAnimationComplete() {
    if (!hasCompletedScaleAnimation) {
      hasCompletedScaleAnimation = true;
      scaleController.forward().then((_) => _onScaleAnimationComplete());
    }
  }

  void _onScaleAnimationComplete() {
    if (mounted) setState(() {});
  }

  double _calculateVerticalMoveOffset() {
    return widget.constraints.maxHeight * logoMoveOffsetRatio;
  }

  double _calculateResponsiveLogoSize() {
    final shortestScreenSide =
        widget.constraints.maxWidth < widget.constraints.maxHeight
        ? widget.constraints.maxWidth
        : widget.constraints.maxHeight;
    return shortestScreenSide * _logoSizeRatio;
  }

  Offset _calculateCircularRevealCenter() {
    return Offset(
      widget.constraints.maxWidth / 2,
      (widget.constraints.maxHeight / 2) - _calculateVerticalMoveOffset(),
    );
  }

  double _calculateCircularRevealMaxRadius() {
    return sqrt(
      widget.constraints.maxWidth * widget.constraints.maxWidth +
          widget.constraints.maxHeight * widget.constraints.maxHeight,
    );
  }

  Color _getAdaptiveBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF6F6F6)
        : const Color(0xFF1E1E1E);
  }

  @override
  void dispose() {
    moveController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupIsCompleted = widget.state is SetUpCompetedState;
    final logoSize = _calculateResponsiveLogoSize();

    return Stack(
      children: [
        if (setupIsCompleted && hasCompletedScaleAnimation)
          _buildCircularRevealExpansion(context),
        _buildTransformingLogo(context, logoSize),
      ],
    );
  }

  Widget _buildTransformingLogo(BuildContext context, double logoSize) {
    return AnimatedBuilder(
      animation: Listenable.merge([moveYAnimation, scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, moveYAnimation.value),
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: Center(
              child: Container(
                width: logoSize,
                height: logoSize,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _getAdaptiveBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
                child: Center(child: DSImage.logo()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularRevealExpansion(BuildContext context) {
    final revealCenter = _calculateCircularRevealCenter();
    final maxRadius = _calculateCircularRevealMaxRadius();
    final logoSize = _calculateResponsiveLogoSize();

    // Calculate the starting radius to match the final transformed logo size
    final transformedLogoRadius = (logoSize * logoFinalScale) / 2;

    return Positioned.fill(
      child:
          ClipPath(
                clipper: _CircularRevealClipper(
                  center: revealCenter,
                  radius: maxRadius,
                ),
                child: Container(color: _getAdaptiveBackgroundColor(context)),
              )
              .animate()
              .custom(
                duration: 600.milliseconds,
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  // Start from the transformed logo radius and expand to max radius
                  final animatedRadius =
                      transformedLogoRadius +
                      (value * (maxRadius - transformedLogoRadius));
                  return ClipPath(
                    clipper: _CircularRevealClipper(
                      center: revealCenter,
                      radius: animatedRadius,
                    ),
                    child: child,
                  );
                },
              )
              .callback(
                duration: 600.milliseconds,
                callback: (_) => widget.onComplete(),
              ),
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  const _CircularRevealClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _CircularRevealClipper &&
        (oldClipper.center != center || oldClipper.radius != radius);
  }
}
