part of 'content_widget.dart';

const _white = DSColor(0xFFFFFFFF);

extension on BuildContext {
  Color get heroStartColor {
    return Color.lerp(colorPalette.brand.primary.color, Colors.black, 0.35)!;
  }

  Color get heroEndColor {
    return Color.lerp(colorPalette.brand.tertiary.color, Colors.black, 0.7)!;
  }
}

/// Full-bleed header that runs from the top edge of the screen. On desktop it
/// hosts the logo header so the gradient continues behind it.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget({required this.expertise, required this.showLogoHeader});

  final ExpertiseEntity expertise;
  final bool showLogoHeader;

  @override
  Widget build(BuildContext context) {
    final isWide = !context.isMobile;
    final summary = expertise.summary;

    final text = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: context.space(factor: 2),
      children: [
        DSTextWidget(
          expertise.title,
          style: isWide
              ? context.typography.displayMedium
              : context.typography.headlineLarge,
          color: _white,
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
        if (summary != null)
          DSTextWidget(
            summary,
            style: context.typography.bodyLarge,
            color: _white,
            textAlign: isWide ? TextAlign.left : TextAlign.center,
          ),
      ],
    ).animate().fadeIn(duration: 500.ms);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.heroStartColor, context.heroEndColor],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: DSFloatingShapesBackgroundWidget(
                color: Colors.white.withAlpha(50),
              ),
            ),
            Positioned.fill(
              child: _ImageAccentsWidget(
                imageUrl: expertise.image,
                opacity: 0.08,
                tint: Colors.white,
              ),
            ),
            Column(
              children: [
                if (showLogoHeader)
                  const PageHeaderWidget()
                else
                  const _BackButtonWidget(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.horizontalPadding,
                    vertical: context.space(factor: isWide ? 5 : 3),
                  ),
                  child: isWide
                      ? Row(
                          spacing: context.space(factor: 4),
                          children: [
                            Expanded(child: text),
                            _EmblemWidget(imageUrl: expertise.image),
                          ],
                        )
                      : Column(
                          spacing: context.space(factor: 3),
                          children: [
                            _EmblemWidget(imageUrl: expertise.image),
                            text,
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmblemWidget extends StatelessWidget {
  const _EmblemWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = context.isMobile ? 150.0 : 240.0;
    final tertiary = context.colorPalette.brand.tertiary.color;

    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedScale(
              scale: isHovering ? 1.08 : 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    DSGradientBlobWidget(
                      size: size,
                      colors: [tertiary.withAlpha(200), Colors.transparent],
                      scaleBegin: const Offset(0.85, 0.85),
                      scaleEnd: const Offset(1.1, 1.1),
                      duration: const Duration(seconds: 4),
                    ),
                    Lottie.asset(
                      AppLottieAssets.expertiseOrbit,
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: size * 0.58,
                      height: size * 0.58,
                      padding: EdgeInsets.all(size * 0.06),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(size * 0.16),
                        boxShadow: [
                          BoxShadow(
                            color: tertiary.withAlpha(isHovering ? 200 : 110),
                            blurRadius: isHovering ? 50 : 30,
                            spreadRadius: isHovering ? 6 : 0,
                          ),
                        ],
                      ),
                      child: DSNetworkImageWidget(
                        url: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(
              begin: -8,
              end: 8,
              duration: 3.seconds,
              curve: Curves.easeInOut,
            );
      },
    );
  }
}

/// Back arrow that sits on the hero gradient, replacing a separate app bar.
class _BackButtonWidget extends StatelessWidget {
  const _BackButtonWidget();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: context.space()),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
