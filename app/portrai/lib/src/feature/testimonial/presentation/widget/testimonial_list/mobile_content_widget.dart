part of 'testimonial_list_widget.dart';

class _MobileContentWidget extends StatelessWidget {
  _MobileContentWidget({required this.testimonials, required this.isVisible});

  final List<TestimonialEntity> testimonials;
  final bool isVisible;

  final ValueNotifier<int> _snappedItemIndex = ValueNotifier<int>(0);

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
              children: testimonials.map((testimonial) {
                return _CardItemWidget(testimonial: testimonial);
              }).toList(),
            )
            .animate(target: isVisible ? 1 : 0)
            .slideY(
              begin: -0.3,
              duration: 300.ms,
              delay: 0.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: 100.ms, duration: 300.ms),
        const DSVerticalSpacerWidget(2),
        DSPositionIndicatorWidget(
              itemCount: testimonials.length,
              indexListener: _snappedItemIndex,
            )
            .animate(target: isVisible ? 1 : 0)
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
