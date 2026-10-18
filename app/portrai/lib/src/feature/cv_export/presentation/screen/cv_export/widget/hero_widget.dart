part of 'content_widget.dart';

/// Gradient header with the logo chrome, the screen title and a short intro.
/// Stacked and centered on mobile and tablet, side by side on desktop.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget();

  static const DSColor _white = DSColor(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isDesktop = context.isDesktop;
    final textAlign = isDesktop ? TextAlign.left : TextAlign.center;

    final text = Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: context.space(),
      children: [
        DSTextWidget(
          context.localizations.cvExportTitle,
          style: context.typography.headlineLarge,
          color: _white,
          textAlign: textAlign,
        ),
        DSTextWidget(
          context.localizations.cvExportIntro,
          style: context.typography.bodyMedium,
          color: _white,
          textAlign: textAlign,
        ),
      ],
    );
    final illustration = DSLottieIllustrationWidget(
      illustration: DSLottieIllustration.talentSearch,
      width: context.space(factor: isDesktop ? 14 : 16),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(palette.brand.primary.color, Colors.black, 0.35)!,
            Color.lerp(palette.brand.tertiary.color, Colors.black, 0.7)!,
          ],
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
            PageChromeWidget(
              closeColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: context.space(factor: 2),
                ),
                child: isDesktop
                    ? Row(
                        spacing: context.space(factor: 4),
                        children: [
                          Expanded(child: text),
                          illustration,
                        ],
                      )
                    : Column(
                        spacing: context.space(),
                        children: [illustration, text],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
