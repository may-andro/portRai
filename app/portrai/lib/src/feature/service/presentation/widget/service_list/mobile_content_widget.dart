part of 'service_list_widget.dart';

const _titleMaxLines = 2;
const _descriptionMaxLines = 3;

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget({required this.services, required this.isVisible});

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
        mainAxisExtent: _MobileItemWidget.getHeight(context),
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return _MobileItemWidget(service: service)
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

class _MobileItemWidget extends StatelessWidget {
  const _MobileItemWidget({required this.service});

  final ServiceEntity service;

  static double getHeight(BuildContext context) {
    return context.space(factor: 2) +
        _ImageWidget.getHeight(context) +
        context.space() +
        DSTitleDescriptionWidget.getHeight(
          context,
          titleMaxLines: _titleMaxLines,
          descriptionMaxLines: _descriptionMaxLines,
        ) +
        context.space(factor: 2);
  }

  @override
  Widget build(BuildContext context) {
    return _CardWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(),
        children: [
          _ImageWidget(imageUrl: service.image),
          DSTitleDescriptionWidget(
            title: service.title,
            description: service.description,
            titleMaxLines: _titleMaxLines,
            descriptionMaxLines: _descriptionMaxLines,
            isCenteredContent: true,
          ),
        ],
      ),
    );
  }
}
