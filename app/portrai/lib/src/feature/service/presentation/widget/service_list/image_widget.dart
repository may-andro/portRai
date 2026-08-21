part of 'service_list_widget.dart';

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({required this.imageUrl});

  final String imageUrl;

  static double getHeight(BuildContext context) {
    return context.imageSize;
  }

  @override
  Widget build(BuildContext context) {
    return DSNetworkImageWidget(
      url: imageUrl,
      shape: BoxShape.rectangle,
      fit: BoxFit.contain,
      borderRadius: BorderRadius.all(
        Radius.circular(context.dimen.radiusLevel3.value),
      ),
      width: getHeight(context),
      height: getHeight(context),
    );
  }
}

extension on BuildContext {
  double get imageSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 10);
      case DSDeviceResolution.tablet:
        return space(factor: 10);
      case DSDeviceResolution.desktop:
        return space(factor: 8);
    }
  }
}
