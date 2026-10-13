part of 'testimonial_list_widget.dart';

const _greyscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

class _CardItemWidget extends StatelessWidget {
  const _CardItemWidget({required this.testimonial});

  final TestimonialEntity testimonial;

  static double _avatarSize(BuildContext context) {
    return context.isMobile
        ? context.space(factor: 6)
        : context.space(factor: 5);
  }

  static double _authorHeight(BuildContext context) {
    final texts =
        context.getTextHeight(context.typography.emphasizedTitleSmall, 1) +
        context.getTextHeight(context.typography.bodySmall, 1);
    return max(_avatarSize(context), texts);
  }

  static double getHeight(BuildContext context) {
    return context.space(factor: 3) +
        context.getTextHeight(context.typography.bodyLarge, context.maxLines) +
        context.space(factor: 2) +
        1 +
        context.space(factor: 2) +
        _authorHeight(context) +
        context.space(factor: 2.5) +
        context.bottomMargin;
  }

  @override
  Widget build(BuildContext context) {
    return DSHoverableContainerWidget(
      builder: (context, isHovering) => _buildCard(context, isHovering),
    );
  }

  Widget _buildCard(BuildContext context, bool isHovering) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    final logoSize = context.space(factor: 22);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isHovering ? -4 : 0, 0),
      height: getHeight(context) - context.bottomMargin,
      margin: context.margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: palette.surface.surfaceContainerLow.color,
        border: Border.all(color: isHovering ? accent : palette.border.color),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(isHovering ? 90 : 36),
            blurRadius: isHovering ? 28 : 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned(
              right: -logoSize * 0.1,
              bottom: -logoSize * 0.1,
              width: logoSize,
              height: logoSize,
              child: AnimatedRotation(
                turns: isHovering ? 0.03 : 0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: isHovering ? 1.2 : 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  child: ColorFiltered(
                    colorFilter: _greyscale,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) {
                        return const RadialGradient(
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.35, 0.85],
                        ).createShader(bounds);
                      },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        opacity: isHovering ? 0.3 : 0.16,
                        child: DSNetworkImageWidget(
                          url: testimonial.companyLogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accent, palette.brand.primary.color],
                  ),
                ),
              ),
            ),
            Positioned(
              left: context.space(factor: 2.5),
              top: context.space(),
              child: DSTextWidget(
                '\u201C',
                style: context.typography.emphasizedDisplayLarge,
                color: DSColor(accent.withAlpha(90).toARGB32()),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.space(factor: 3),
                context.space(factor: 3),
                context.space(factor: 2.5),
                context.space(factor: 2.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DSTextWidget(
                      testimonial.testimonial,
                      style: context.typography.bodyLarge,
                      color: palette.neutral.grey9,
                      maxLines: context.maxLines,
                      textOverflow: TextOverflow.ellipsis,
                      isItalic: true,
                    ),
                  ),
                  SizedBox(height: context.space(factor: 2)),
                  Container(height: 1, color: palette.border.color),
                  SizedBox(height: context.space(factor: 2)),
                  _AuthorWidget(
                    testimonial: testimonial,
                    isHovering: isHovering,
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

class _AuthorWidget extends StatelessWidget {
  const _AuthorWidget({required this.testimonial, required this.isHovering});

  final TestimonialEntity testimonial;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final size = _CardItemWidget._avatarSize(context);
    final image = testimonial.profileImage;

    return Row(
      spacing: context.space(factor: 1.5),
      children: [
        AnimatedScale(
          scale: isHovering ? 1.12 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: AnimatedRotation(
            turns: isHovering ? -0.02 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [palette.accent.color, palette.brand.primary.color],
                ),
              ),
              child: image == null
                  ? CircleAvatar(
                      backgroundColor: palette.surface.surface.color,
                      child: Icon(
                        Icons.person,
                        size: size / 2,
                        color: palette.brand.primary.color,
                      ),
                    )
                  : DSNetworkImageWidget(
                      url: image,
                      shape: BoxShape.circle,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                testimonial.name,
                style: context.typography.emphasizedTitleSmall,
                color: palette.neutral.grey10,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              DSTextWidget(
                '${testimonial.position} · ${testimonial.company}',
                style: context.typography.bodySmall,
                color: palette.neutral.grey7,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on BuildContext {
  EdgeInsets? get margin {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return EdgeInsets.only(
          left: space(factor: 3),
          right: space(factor: 3),
          bottom: bottomMargin,
        );
      case DSDeviceResolution.tablet:
        return null;
      case DSDeviceResolution.desktop:
        return EdgeInsets.only(bottom: bottomMargin);
    }
  }

  double get bottomMargin {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space();
      case DSDeviceResolution.tablet:
        return 0;
      case DSDeviceResolution.desktop:
        return space();
    }
  }

  int get maxLines {
    switch (deviceWidth) {
      case DSDeviceWidthResolution.xs:
        return isiOS
            ? 8
            : isAndroid
            ? 6
            : 5;
      case DSDeviceWidthResolution.s:
        return 3;
      case DSDeviceWidthResolution.m:
        return 6;
      case DSDeviceWidthResolution.l:
        return 4;
      case DSDeviceWidthResolution.xl:
        return 3;
    }
  }
}
