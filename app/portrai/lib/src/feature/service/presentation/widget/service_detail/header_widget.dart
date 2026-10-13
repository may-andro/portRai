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
                    children: [
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
                  Padding(
                    padding: EdgeInsets.only(right: context.space(factor: 6)),
                    child: DSTextWidget(
                      service.title,
                      style: context.typography.emphasizedHeadlineSmall,
                      color: const DSColor(0xFFFFFFFF),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: context.space(factor: 6)),
                    child: DSTextWidget(
                      service.description,
                      style: context.typography.bodyMedium,
                      color: const DSColor(0xFFFFFFFF),
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

class _FooterArtWidget extends StatelessWidget {
  const _FooterArtWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final start = Color.lerp(palette.brand.primary.color, Colors.black, 0.35)!;
    final end = Color.lerp(palette.brand.tertiary.color, Colors.black, 0.45)!;
    final artSize = context.space(factor: 30);

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
      child: SizedBox(
        width: double.infinity,
        height: context.space(factor: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [start, end],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -artSize * 0.1,
                bottom: -artSize * 0.3,
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
                      opacity: 0.5,
                      child: DSNetworkImageWidget(
                        url: imageUrl,
                        fit: BoxFit.contain,
                      ),
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
