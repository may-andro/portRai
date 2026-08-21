part of 'footer_widget.dart';

class _IntroWidget extends StatelessWidget {
  const _IntroWidget();

  static double getHeight(BuildContext context) {
    return max(
      _ImageWidget.getHeight(context),
      _TaglineWidget.getHeight(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(),
        mainAxisSize: MainAxisSize.min,
        children: const [
          _ImageWidget(),
          Flexible(child: Center(child: _TaglineWidget())),
        ],
      ),
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
    return Image.asset(
      DSImage.logoPath,
      package: 'design_system',
      color: context.colorPalette.surface.onInverseSurface.color,
      height: getHeight(context),
      width: getHeight(context),
    );
  }
}

class _TaglineWidget extends StatelessWidget {
  const _TaglineWidget();

  static double getHeight(BuildContext context) {
    return context.nameTextHeight +
        context.taglineTextHeight +
        context.space(factor: 0.25);
  }

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
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

extension on BuildContext {
  DSTextStyle get nameTextStyle => typography.emphasizedTitleMedium;

  DSTextStyle get taglineTextStyle => typography.labelSmall;

  double get nameTextHeight => getTextHeight(nameTextStyle, 1);

  double get taglineTextHeight => getTextHeight(taglineTextStyle, 1);
}
