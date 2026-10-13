part of 'professional_summary_widget.dart';

class _ProjectBackdropWidget extends StatelessWidget {
  const _ProjectBackdropWidget({
    required this.imageUrls,
    required this.isVisible,
  });

  final List<String> imageUrls;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final surface = context.colorPalette.surface.surface.color;
    final columnCount = context.isMobile ? 3 : (context.isTablet ? 4 : 6);
    final tileHeight = context.space(factor: context.isMobile ? 18 : 26);
    final gap = context.space(factor: 2);

    return IgnorePointer(
      child: RepaintBoundary(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.16,
                child: Transform.rotate(
                  angle: -0.14,
                  child: Transform.scale(
                    scale: 1.5,
                    child: Row(
                      spacing: gap,
                      children: List.generate(columnCount, (column) {
                        return Expanded(
                          child: _DriftingColumnWidget(
                            imageUrls: [
                              ...imageUrls.skip(column % imageUrls.length),
                              ...imageUrls.take(column % imageUrls.length),
                            ],
                            tileHeight: tileHeight,
                            gap: gap,
                            isReversed: column.isOdd,
                            duration: Duration(seconds: 40 + column * 6),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ).animate(target: isVisible ? 1 : 0).fadeIn(duration: 600.ms),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      surface.withAlpha(235),
                      surface.withAlpha(120),
                      surface.withAlpha(235),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, 0.4),
                    radius: 0.9,
                    colors: [
                      context.colorPalette.brand.primary.color.withAlpha(60),
                      Colors.transparent,
                    ],
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

class _DriftingColumnWidget extends StatelessWidget {
  const _DriftingColumnWidget({
    required this.imageUrls,
    required this.tileHeight,
    required this.gap,
    required this.isReversed,
    required this.duration,
  });

  final List<String> imageUrls;
  final double tileHeight;
  final double gap;
  final bool isReversed;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final setHeight = imageUrls.length * (tileHeight + gap);
    final radius = context.dimen.radiusLevel2.value;

    // Three copies keep the column filled while the loop translates by one set.
    final tiles = [
      for (var copy = 0; copy < 3; copy++)
        for (final url in imageUrls)
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: SizedBox(
              height: tileHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: DSNetworkImageWidget(url: url, fit: BoxFit.cover),
              ),
            ),
          ),
    ];

    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Column(mainAxisSize: MainAxisSize.min, children: tiles)
          .animate(onPlay: (controller) => controller.repeat())
          .moveY(
            begin: isReversed ? -setHeight : -setHeight * 0.1,
            end: isReversed ? -setHeight * 0.1 : -setHeight,
            duration: duration,
            curve: Curves.linear,
          ),
    );
  }
}
