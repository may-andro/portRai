part of 'testimonial_list_widget.dart';

class _CardItemWidget extends StatelessWidget {
  const _CardItemWidget({required this.testimonial});

  final TestimonialEntity testimonial;

  static double getHeight(BuildContext context) {
    return context.space(factor: 2) +
        DSQuoteTextWidget.getHeight(context, maxLines: context.maxLines) +
        context.space(factor: 2) +
        DSAvatarNameWidget.getHeight(context) +
        context.space(factor: 2) +
        context.bottomMargin;
  }

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      elevation: context.dimen.elevationLevel1,
      backgroundColor: context.colorPalette.containerHighest,
      radius: context.dimen.radiusLevel2,
      margin: context.margin,
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(),
          children: [
            DSQuoteTextWidget(
              text: testimonial.testimonial,
              maxLines: context.maxLines,
            ),
            DSAvatarNameWidget(
              name: testimonial.name,
              caption: testimonial.position,
              imageUrl: testimonial.profileImage,
            ),
          ],
        ),
      ),
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
