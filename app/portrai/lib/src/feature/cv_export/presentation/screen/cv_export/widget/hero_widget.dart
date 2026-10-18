part of 'content_widget.dart';

/// Gradient header with the logo chrome, the screen title and a short intro.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget();

  static const DSColor _white = DSColor(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isWide = !context.isMobile;
    final alignment = isWide
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = isWide ? TextAlign.left : TextAlign.center;

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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ContentWidget.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.space(factor: 2),
                      vertical: context.space(factor: isWide ? 5 : 3),
                    ),
                    child: Row(
                      spacing: context.space(factor: 3),
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: alignment,
                            spacing: context.space(factor: 2),
                            children: [
                              DSTextWidget(
                                context.localizations.cvExportTitle,
                                style: isWide
                                    ? context.typography.displayMedium
                                    : context.typography.headlineLarge,
                                color: _white,
                                textAlign: textAlign,
                              ),
                              DSTextWidget(
                                context.localizations.cvExportIntro,
                                style: context.typography.bodyLarge,
                                color: _white,
                                textAlign: textAlign,
                              ),
                            ],
                          ),
                        ),
                        DSLottieIllustrationWidget(
                          illustration: DSLottieIllustration.talentSearch,
                          width: context.space(factor: isWide ? 28 : 14),
                        ),
                      ],
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
