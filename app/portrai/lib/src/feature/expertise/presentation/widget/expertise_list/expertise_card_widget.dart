part of 'expertise_list_widget.dart';

const _maxSkills = 8;
const _white = DSColor(0xFFFFFFFF);

class _ExpertiseCardWidget extends StatelessWidget {
  const _ExpertiseCardWidget({
    required this.expertise,
    required this.index,
    required this.onOpen,
  });

  final ExpertiseEntity expertise;
  final int index;
  final ValueChanged<ExpertiseEntity>? onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final base = [
      palette.brand.primary,
      palette.brand.tertiary,
      palette.brand.secondary,
    ][index % 3].color;
    final start = Color.lerp(base, Colors.black, 0.25)!;
    final end = Color.lerp(base, Colors.black, 0.65)!;
    final skills = expertise.skillNames;
    final hiddenCount = skills.length - _maxSkills;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    final artSize = context.space(factor: 20);

    return GestureDetector(
      onTap: () {
        onOpen?.call(expertise);
        ExpertiseScreen.navigate(context, expertise: expertise);
      },
      child: DSHoverableContainerWidget(
        builder: (context, isHovering) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, isHovering ? -4 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [start, end],
              ),
              boxShadow: [
                BoxShadow(
                  color: base.withAlpha(isHovering ? 150 : 90),
                  blurRadius: isHovering ? 28 : 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned(
                    right: -artSize * 0.2,
                    bottom: -artSize * 0.25,
                    width: artSize,
                    height: artSize,
                    child: AnimatedRotation(
                      turns: isHovering ? 0.07 : 0.04,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: isHovering ? 1.15 : 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) {
                            return const RadialGradient(
                              colors: [Colors.black, Colors.transparent],
                              stops: [0.55, 1],
                            ).createShader(bounds);
                          },
                          child: AnimatedOpacity(
                            opacity: isHovering ? 0.45 : 0.28,
                            duration: const Duration(milliseconds: 500),
                            child: DSNetworkImageWidget(
                              url: expertise.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(context.space(factor: 2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: context.space(factor: 1.5),
                      children: [
                        Row(
                          spacing: context.space(factor: 1.5),
                          children: [
                            _IconTileWidget(imageUrl: expertise.image),
                            Expanded(
                              child: DSTextWidget(
                                expertise.title,
                                style: context.typography.emphasizedTitleLarge,
                                color: _white,
                                maxLines: 2,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: context.space(factor: 0.5),
                          runSpacing: context.space(factor: 0.5),
                          children: [
                            for (final skill in skills.take(_maxSkills))
                              _GlassChipWidget(label: skill),
                            if (hiddenCount > 0)
                              _GlassChipWidget(label: '+$hiddenCount'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IconTileWidget extends StatelessWidget {
  const _IconTileWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 6);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12)],
      ),
      child: DSNetworkImageWidget(
        url: imageUrl,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel1.value),
      ),
    );
  }
}

class _GlassChipWidget extends StatelessWidget {
  const _GlassChipWidget({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 0.5),
        vertical: context.space(factor: 0.125),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: DSTextWidget(
        label,
        style: context.typography.labelSmall,
        color: _white,
      ),
    );
  }
}
