part of 'personal_summary_widget.dart';

class _ProfileImageWidget extends StatelessWidget {
  const _ProfileImageWidget({
    required this.url,
    required this.isVisible,
    required this.height,
  });

  final String url;
  final bool isVisible;
  final double height;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.accent.color;

    return DSHoverableContainerWidget(
          builder: (context, isHovering) {
            return AnimatedScale(
              duration: 350.ms,
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              scale: isHovering ? 1.05 : 1,
              child: DSArchPortraitWidget(
                height: height * 0.9,
                gradientColors: [accent.withAlpha(140), accent],
                outlineColor: accent.withAlpha(160),
                child: DSNetworkImageWidget(
                  url: url,
                  fit: BoxFit.fitHeight,
                  autoSizeImage: true,
                ),
              ),
            );
          },
        )
        .animate(target: isVisible ? 1 : 0)
        .slideY(begin: 0.15, duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 400.ms);
  }
}
