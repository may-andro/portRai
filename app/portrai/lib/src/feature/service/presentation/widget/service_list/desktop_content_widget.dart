part of 'service_list_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({
    required this.services,
    required this.isVisible,
  });

  final List<ServiceEntity> services;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: services.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.space(),
        mainAxisSpacing: context.space(),
        mainAxisExtent: _DesktopItemWidget.getHeight(context),
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return _DesktopItemWidget(service: service)
            .animate(target: isVisible ? 1 : 0)
            .slideY(
              begin: 1 + (index * 0.2),
              duration: 300.ms,
              delay: (100 + index * 100).ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
      },
    );
  }
}

class _DesktopItemWidget extends StatelessWidget {
  const _DesktopItemWidget({required this.service});

  final ServiceEntity service;

  static double getHeight(BuildContext context) {
    return context.space(factor: 2) +
        _ImageWidget.getHeight(context) +
        context.space() +
        DSTitleDescriptionWidget.getHeight(
          context,
          descriptionMaxLines: context.desktopMaxLines,
          titleMaxLines: 1,
        ) +
        context.space(factor: 2);
  }

  @override
  Widget build(BuildContext context) {
    return _CardWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(),
        children: [
          _ImageWidget(imageUrl: service.image),
          DSTitleDescriptionWidget(
            title: service.title,
            description: service.detail,
            descriptionMaxLines: context.desktopMaxLines,
            titleMaxLines: 1,
            isCenteredContent: true,
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  int get desktopMaxLines {
    switch (deviceWidth) {
      case DSDeviceWidthResolution.xs:
      case DSDeviceWidthResolution.s:
      case DSDeviceWidthResolution.m:
        return 5;
      case DSDeviceWidthResolution.l:
        return 4;
      case DSDeviceWidthResolution.xl:
        return 3;
    }
  }
}
