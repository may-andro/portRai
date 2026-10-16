part of 'footer_widget.dart';

class _IntroWidget extends StatelessWidget {
  const _IntroWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.space(),
      mainAxisSize: MainAxisSize.min,
      children: const [
        _ImageWidget(),
        Flexible(child: _TaglineWidget()),
      ],
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget();

  static double getHeight(BuildContext context) {
    return context.space(factor: 7);
  }

  @override
  Widget build(BuildContext context) {
    // The logo shrinks on narrow layouts so the tagline keeps its room.
    final size = min(
      getHeight(context),
      MediaQuery.sizeOf(context).width * 0.15,
    );
    return Image.asset(
      DSImage.logoPath,
      package: 'design_system',
      color: context.colorPalette.surface.onInverseSurface.color,
      height: size,
      width: size,
    );
  }
}

class _TaglineWidget extends StatelessWidget {
  const _TaglineWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 0.25),
      children: [
        DSTextWidget(
          context.localizations.companyName,
          style: context.nameTextStyle,
          color: context.colorPalette.onInverseSurface,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        DSTextWidget(
          context.localizations.footerPitch,
          style: context.taglineTextStyle,
          color: context.colorPalette.onInverseSurface,
          maxLines: 3,
          textOverflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

extension on BuildContext {
  DSTextStyle get nameTextStyle => typography.emphasizedTitleMedium;

  DSTextStyle get taglineTextStyle => typography.labelSmall;
}
