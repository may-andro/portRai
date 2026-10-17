part of 'content_widget.dart';

class _BackgroundWidget extends StatelessWidget {
  const _BackgroundWidget();

  @override
  Widget build(BuildContext context) {
    final brand = context.colorPalette.brand;
    final blobSize = context.width * (context.isMobile ? 1.1 : 0.6);

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: DSFloatingShapesBackgroundWidget(
                  color: brand.primary.color.withAlpha(60),
                ),
              ),
            ),
            Positioned(
              top: -blobSize * 0.35,
              left: -blobSize * 0.3,
              child: DSGradientBlobWidget(
                size: blobSize,
                colors: [brand.primary.color.withAlpha(90), Colors.transparent],
                scaleBegin: const Offset(0.9, 0.9),
                scaleEnd: const Offset(1.1, 1.1),
                duration: const Duration(seconds: 6),
              ),
            ),
            Positioned(
              bottom: -blobSize * 0.35,
              right: -blobSize * 0.3,
              child: DSGradientBlobWidget(
                size: blobSize,
                colors: [
                  brand.tertiary.color.withAlpha(90),
                  Colors.transparent,
                ],
                scaleBegin: const Offset(1.1, 1.1),
                scaleEnd: const Offset(0.9, 0.9),
                duration: const Duration(seconds: 7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
