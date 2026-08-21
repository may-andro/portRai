part of 'personal_summary_widget.dart';

class _ProfileImageWidget extends StatelessWidget {
  const _ProfileImageWidget({
    required this.url,
    required this.isVisible,
    this.animationDelay = Duration.zero,
    this.fit = BoxFit.cover,
  });

  final String url;
  final Duration animationDelay;
  final bool isVisible;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              alignment: Alignment.bottomCenter,
              width: constraints.maxHeight,
              height: constraints.maxWidth,
              decoration: const BoxDecoration(),
              clipBehavior: Clip.antiAlias,
              child: DSNetworkImageWidget(url: url, fit: fit),
            );
          },
        )
        .animate(target: isVisible ? 1 : 0)
        .slideY(
          begin: 0.3,
          duration: 300.ms,
          delay: animationDelay,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: 100.ms, duration: 300.ms);
  }
}
