part of 'expertise_list_widget.dart';

const _maxSkills = 8;

class _ExpertiseCardWidget extends StatelessWidget {
  const _ExpertiseCardWidget({required this.expertise, required this.index});

  final ExpertiseEntity expertise;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final textColor = palette.surface.onInverseSurface;
    final accent = [
      palette.brand.primary,
      palette.brand.tertiary,
      palette.brand.secondary,
    ][index % 3];
    final skills = expertise.skillNames;
    final hiddenCount = skills.length - _maxSkills;

    return DSSpotlightCardWidget(
      glowColor: accent,
      fillColor: textColor,
      padding: EdgeInsets.all(context.space(factor: 2.5)),
      builder: (context, isHovering) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 1.5),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconTileWidget(
                  imageUrl: expertise.image,
                  color: accent,
                  isHovering: isHovering,
                ),
                const Spacer(),
                _CountPillWidget(count: skills.length, color: accent),
              ],
            ),
            DSTextWidget(
              expertise.title,
              style: context.typography.emphasizedHeadlineSmall,
              color: textColor,
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
            Container(
              height: 3,
              width: isHovering ? 64 : 32,
              decoration: BoxDecoration(
                color: accent.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Wrap(
              spacing: context.space(factor: 0.5),
              runSpacing: context.space(factor: 0.5),
              children: [
                for (final skill in skills.take(_maxSkills))
                  DSTagWidget(label: skill),
                if (hiddenCount > 0) DSTagWidget(label: '+$hiddenCount'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _IconTileWidget extends StatelessWidget {
  const _IconTileWidget({
    required this.imageUrl,
    required this.color,
    required this.isHovering,
  });

  final String imageUrl;
  final DSColor color;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 7);

    return AnimatedScale(
      scale: isHovering ? 1.06 : 1,
      duration: const Duration(milliseconds: 250),
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.color, color.color.withAlpha(60)],
          ),
          boxShadow: [
            BoxShadow(color: color.color.withAlpha(90), blurRadius: 18),
          ],
        ),
        child: DSNetworkImageWidget(
          url: imageUrl,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        ),
      ),
    );
  }
}

class _CountPillWidget extends StatelessWidget {
  const _CountPillWidget({required this.count, required this.color});

  final int count;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.25),
        vertical: context.space(factor: 0.5),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.color.withAlpha(140)),
        color: color.color.withAlpha(30),
      ),
      child: DSTextWidget(
        '$count',
        style: context.typography.emphasizedLabelLarge,
        color: context.colorPalette.surface.onInverseSurface,
      ),
    );
  }
}
