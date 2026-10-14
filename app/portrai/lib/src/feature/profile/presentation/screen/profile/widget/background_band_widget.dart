part of 'content_widget.dart';

/// Thin strip over a darkened photo listing the education in one line.
class _BackgroundBandWidget extends StatelessWidget {
  const _BackgroundBandWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (profile.educations.isEmpty) return const SizedBox.shrink();
    final palette = context.colorPalette;

    return _BandWidget(
      verticalFactor: isDesktop ? 4 : 3,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/profile/education.jpg', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(215),
                  Color.alphaBlend(
                    palette.brand.primary.color.withAlpha(120),
                    Colors.black.withAlpha(150),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Wrap(
        spacing: context.space(factor: 5),
        runSpacing: context.space(factor: 2),
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _EyebrowWidget(context.localizations.profileEducation, onDark: true),
          for (final education in profile.educations)
            _EducationStripItemWidget(education: education),
        ],
      ),
    );
  }
}

class _EducationStripItemWidget extends StatelessWidget {
  const _EducationStripItemWidget({required this.education});

  final EducationEntity education;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftWidget(
      scale: 1.03,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 1.5),
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: DSLottieIllustrationWidget(
                illustration: DSLottieIllustration.graduationHat,
                width: 40,
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSTextWidget(
                  '${education.degree} · ${education.field}',
                  style: context.typography.emphasizedBodyLarge,
                  color: _white,
                ),
                DSTextWidget(
                  '${education.institution}, ${education.location}',
                  style: context.typography.bodySmall,
                  color: _white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
