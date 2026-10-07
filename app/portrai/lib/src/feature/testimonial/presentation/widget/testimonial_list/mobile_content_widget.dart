part of 'testimonial_list_widget.dart';

class _MobileContentWidget extends StatefulWidget {
  const _MobileContentWidget({
    required this.testimonials,
    required this.isVisible,
  });

  final List<TestimonialEntity> testimonials;
  final bool isVisible;

  @override
  State<_MobileContentWidget> createState() => _MobileContentWidgetState();
}

class _MobileContentWidgetState extends State<_MobileContentWidget> {
  final ValueNotifier<int> _snappedItemIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _snappedItemIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DSCarousalWidget(
              height: _CardItemWidget.getHeight(context),
              autoPlay: true,
              enableInfiniteScroll: true,
              onPageChanged: (index, _) {
                _snappedItemIndex.value = index;
              },
              children: widget.testimonials.map((testimonial) {
                return _CardItemWidget(testimonial: testimonial);
              }).toList(),
            )
            .animate(target: widget.isVisible ? 1 : 0)
            .slideY(
              begin: -0.3,
              duration: 300.ms,
              delay: 0.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: 100.ms, duration: 300.ms),
        const DSVerticalSpacerWidget(2),
        DSPositionIndicatorWidget(
              itemCount: widget.testimonials.length,
              indexListener: _snappedItemIndex,
            )
            .animate(target: widget.isVisible ? 1 : 0)
            .slideY(
              begin: -0.3,
              duration: 300.ms,
              delay: 200.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: 100.ms, duration: 300.ms),
      ],
    );
  }
}
