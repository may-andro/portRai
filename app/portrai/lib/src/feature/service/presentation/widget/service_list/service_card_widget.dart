part of 'service_list_widget.dart';

const _maxTechnologies = 4;

class _ServiceCardWidget extends StatelessWidget {
  const _ServiceCardWidget({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorPalette.surface.onSurface;
    final accent = context.colorPalette.brand.tertiary;
    final technologies = service.technologies;
    final hiddenCount = technologies.length - _maxTechnologies;

    return DSSpotlightCardWidget(
      glowColor: accent,
      background: ColoredBox(
        color: context.colorPalette.surface.surfaceContainer.color,
        child: _BackgroundArtWidget(imageUrl: service.image),
      ),
      fillColor: textColor,
      padding: EdgeInsets.all(context.space(factor: 2)),
      onTap: () {
        context.bloc.add(
          ServiceClickEvent(label: 'service_card', serviceTitle: service.title),
        );
        ServiceScreen.navigate(context, service: service);
      },
      builder: (context, isHovering) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 1.5),
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(factor: 0.5),
                    children: [
                      DSTextWidget(
                        service.title,
                        style: context.typography.emphasizedTitleMedium,
                        color: textColor,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      DSTextWidget(
                        service.description,
                        style: context.typography.bodyMedium,
                        color: textColor,
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _ArrowWidget(isHovering: isHovering),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: context.space(factor: 0.5),
              runSpacing: context.space(factor: 0.5),
              children: [
                for (final technology in technologies.take(_maxTechnologies))
                  DSTagWidget(label: technology),
                if (hiddenCount > 0) DSTagWidget(label: '+$hiddenCount'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BackgroundArtWidget extends StatelessWidget {
  const _BackgroundArtWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 26);

    return Stack(
      children: [
        Positioned(
          right: -size * 0.12,
          bottom: -size * 0.12,
          width: size,
          height: size,
          child: Transform.rotate(
            angle: -0.2,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) {
                return const RadialGradient(
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.55, 1],
                ).createShader(bounds);
              },
              child: Opacity(
                opacity: 0.22,
                child: DSNetworkImageWidget(url: imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowWidget extends StatelessWidget {
  const _ArrowWidget({required this.isHovering});

  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.brand.tertiaryContainer.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(context.space(factor: 0.5)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withAlpha(isHovering ? 255 : 220),
      ),
      child: Icon(
        Icons.arrow_outward_rounded,
        size: 18,
        color: context.colorPalette.brand.onTertiaryContainer.color,
      ),
    );
  }
}
