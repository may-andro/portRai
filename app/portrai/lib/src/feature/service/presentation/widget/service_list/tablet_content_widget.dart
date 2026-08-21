part of 'service_list_widget.dart';

class _TabletContentWidget extends StatelessWidget {
  const _TabletContentWidget({required this.services, required this.isVisible});

  final List<ServiceEntity> services;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: services.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      cacheExtent: _TabletItemWidget.getHeight(context),
      separatorBuilder: (_, index) {
        return const DSVerticalSpacerWidget(1);
      },
      itemBuilder: (context, index) {
        final service = services[index];
        return _TabletItemWidget(service: service)
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

class _TabletItemWidget extends StatelessWidget {
  const _TabletItemWidget({required this.service});

  final ServiceEntity service;

  static double getHeight(BuildContext context) {
    return context.space(factor: 2) +
        max(
          _ImageWidget.getHeight(context),
          DSTitleDescriptionWidget.getHeight(
            context,
            descriptionMaxLines: context.tabletMaxLines,
            titleMaxLines: 1,
          ),
        ) +
        context.space() +
        context.space(factor: 2);
  }

  @override
  Widget build(BuildContext context) {
    return _CardWidget(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 2),
        children: [
          _ImageWidget(imageUrl: service.image),
          Expanded(
            child: DSTitleDescriptionWidget(
              title: service.title,
              description: service.detail,
              descriptionMaxLines: context.tabletMaxLines,
              titleMaxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  int get tabletMaxLines {
    switch (deviceWidth) {
      case DSDeviceWidthResolution.xs:
      case DSDeviceWidthResolution.s:
        return 4;
      case DSDeviceWidthResolution.m:
        return 3;
      case DSDeviceWidthResolution.l:
      case DSDeviceWidthResolution.xl:
        return 2;
    }
  }
}
