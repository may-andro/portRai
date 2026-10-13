part of 'service_detail_widget.dart';

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final start = Color.lerp(palette.brand.primary.color, Colors.black, 0.35)!;
    final end = Color.lerp(palette.brand.tertiary.color, Colors.black, 0.45)!;
    final tileSize = context.space(factor: 9);
    final artSize = context.space(factor: 22);

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [start, end],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -artSize * 0.15,
              bottom: -artSize * 0.2,
              width: artSize,
              height: artSize,
              child: Transform.rotate(
                angle: -0.2,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) {
                    return const RadialGradient(
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.6, 1],
                    ).createShader(bounds);
                  },
                  child: Opacity(
                    opacity: 0.55,
                    child: DSNetworkImageWidget(
                      url: service.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.space(factor: 2.5),
                context.space(factor: 2.5),
                context.space(factor: 2.5),
                context.space(factor: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(factor: 1.5),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: tileSize,
                        height: tileSize,
                        padding: EdgeInsets.all(context.space(factor: 0.75)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            context.dimen.radiusLevel3.value,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 16),
                          ],
                        ),
                        child: DSNetworkImageWidget(
                          url: service.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        tooltip: context.localizations.close,
                        onPressed: context.popScreen,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: context.space(factor: 6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: context.space(factor: 0.25),
                      children: [
                        DSTextWidget(
                          service.title,
                          style: context.typography.emphasizedHeadlineMedium,
                          color: const DSColor(0xFFFFFFFF),
                        ),
                        DSTextWidget(
                          service.description,
                          style: context.typography.titleSmall,
                          color: const DSColor(0xFFFFFFFF),
                          isItalic: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
