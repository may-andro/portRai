part of 'content_widget.dart';

class _HeroWidget extends StatefulWidget {
  const _HeroWidget({required this.service});

  final ServiceEntity service;

  @override
  State<_HeroWidget> createState() => _HeroWidgetState();
}

class _HeroWidgetState extends State<_HeroWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !context.isMobile;
    final palette = context.colorPalette;

    return ColoredBox(
      color: palette.background.color,
      child: PageChromeWidget(
        closeColor: palette.neutral.grey10.color,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: _HeroAtmosphereWidget(animation: _backgroundController),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: context.space(factor: isWide ? 6 : 4),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: isWide
                        ? Row(
                            spacing: context.space(factor: 4),
                            children: [
                              Expanded(
                                child: _HeroCopyWidget(
                                  service: widget.service,
                                  isWide: true,
                                ),
                              ),
                              _ServiceIconWidget(
                                imageUrl: widget.service.image,
                                animation: _backgroundController,
                                isMobile: false,
                              ),
                            ],
                          )
                        : Column(
                            spacing: context.space(factor: 3),
                            children: [
                              _ServiceIconWidget(
                                imageUrl: widget.service.image,
                                animation: _backgroundController,
                                isMobile: true,
                              ),
                              _HeroCopyWidget(
                                service: widget.service,
                                isWide: false,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceIconWidget extends StatelessWidget {
  const _ServiceIconWidget({
    required this.imageUrl,
    required this.animation,
    required this.isMobile,
  });

  final String imageUrl;
  final Animation<double> animation;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final iconSize = isMobile ? 116.0 : 176.0;
    final shapeSize = iconSize * 1.32;

    return SizedBox.square(
      dimension: shapeSize,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final floatOffset = (animation.value - 0.5) * 12;
          final tilt = (animation.value - 0.5) * 0.12;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              DSLottieIllustrationWidget(
                illustration: DSLottieIllustration.pinPulse,
                width: shapeSize * 1.8,
              ),
              Transform.translate(
                offset: Offset(-floatOffset * 0.4, floatOffset * 0.35),
                child: Container(
                  width: shapeSize * 0.9,
                  height: shapeSize * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.brand.primary.color.withAlpha(28),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(floatOffset * 0.35, -floatOffset * 0.5),
                child: Container(
                  width: shapeSize,
                  height: shapeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accent.color.withAlpha(100),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: shapeSize * 0.08,
                right: shapeSize * 0.12,
                child: Transform.translate(
                  offset: Offset(0, -floatOffset),
                  child: Icon(
                    Icons.add_rounded,
                    size: isMobile ? 18 : 23,
                    color: palette.accent.color,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: tilt,
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    padding: EdgeInsets.all(iconSize * 0.045),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        context.dimen.radiusLevel3.value * 1.25,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: palette.neutral.grey10.color.withAlpha(70),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: DSNetworkImageWidget(
                      url: imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroAtmosphereWidget extends StatelessWidget {
  const _HeroAtmosphereWidget({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final shapeSize = context.isMobile ? 190.0 : 320.0;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final drift = (animation.value - 0.5) * 22;
          final rotation = (animation.value - 0.5) * 0.08;

          return Stack(
            fit: StackFit.expand,
            children: [
              DSFloatingShapesBackgroundWidget(
                color: palette.brand.tertiary.color.withAlpha(70),
              ),
              Positioned(
                right: context.isMobile ? -42 : 70,
                bottom: context.isMobile ? -100 : -145,
                child: Transform.translate(
                  offset: Offset(-drift * 0.45, drift * 0.35),
                  child: Container(
                    width: shapeSize * 1.5,
                    height: shapeSize * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.brand.tertiary.color.withAlpha(55),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: context.isMobile ? shapeSize * 0.12 : shapeSize * 0.75,
                top: context.isMobile ? 12 : 24,
                child: Transform.translate(
                  offset: Offset(0, drift * 0.6),
                  child: Icon(
                    Icons.add_rounded,
                    size: context.isMobile ? 22 : 30,
                    color: palette.accent.color.withAlpha(155),
                  ),
                ),
              ),
              Positioned(
                right: context.isMobile ? shapeSize * 0.7 : shapeSize * 0.25,
                top: context.isMobile ? 48 : 65,
                child: Transform.rotate(
                  angle: rotation * 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: palette.brand.secondary.color.withAlpha(150),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.background.color,
                      palette.background.color.withAlpha(210),
                      palette.background.color.withAlpha(20),
                    ],
                    stops: const [0, 0.58, 1],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCopyWidget extends StatelessWidget {
  const _HeroCopyWidget({required this.service, required this.isWide});

  final ServiceEntity service;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, entranceProgress, child) {
        return Opacity(
          opacity: entranceProgress,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - entranceProgress)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: isWide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 1.25),
        children: [
          Container(
            width: isWide ? context.space(factor: 5) : context.space(factor: 8),
            height: 4,
            decoration: BoxDecoration(
              color: palette.accent.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          DSTextWidget(
            service.title,
            style: isWide
                ? context.typography.displayMedium
                : context.typography.headlineMedium,
            color: palette.neutral.grey10,
            textAlign: isWide ? TextAlign.left : TextAlign.center,
          ),
          DSTextWidget(
            service.description,
            style: context.typography.bodyLarge,
            color: palette.neutral.grey8,
            textAlign: isWide ? TextAlign.left : TextAlign.center,
          ),
        ],
      ),
    );
  }
}
