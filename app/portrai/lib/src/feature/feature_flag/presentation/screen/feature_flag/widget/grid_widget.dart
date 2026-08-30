part of 'content_widget.dart';

class _GridWidget extends StatelessWidget {
  const _GridWidget({required this.flags});

  final List<AppFeatureFlagEntity> flags;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.crossAxisCount,
        crossAxisSpacing: context.space(factor: 2),
        mainAxisSpacing: context.space(factor: 2),
        childAspectRatio: context.childAspectRatio,
      ),
      itemCount: flags.length,
      itemBuilder: (context, index) {
        return _GridItemWidget(flag: flags[index]);
      },
    );
  }
}

extension on BuildContext {
  int get crossAxisCount {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return 3;
      case DSDeviceResolution.tablet:
        return 5;
      case DSDeviceResolution.desktop:
        return 7;
    }
  }

  double get childAspectRatio {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return 1.0;
      case DSDeviceResolution.tablet:
        return 1.3;
      case DSDeviceResolution.desktop:
        return 1.5;
    }
  }
}
