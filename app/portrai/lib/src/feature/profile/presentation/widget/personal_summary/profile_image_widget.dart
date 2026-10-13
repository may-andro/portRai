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

    return DSArchPortraitWidget(
          height: height,
          gradientColors: [accent.withAlpha(140), accent],
          outlineColor: accent.withAlpha(160),
          child: DSNetworkImageWidget(
            url: url,
            fit: BoxFit.fitWidth,
            autoSizeImage: true,
          ),
        )
        .animate(target: isVisible ? 1 : 0)
        .slideY(begin: 0.15, duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 400.ms);
  }
}
