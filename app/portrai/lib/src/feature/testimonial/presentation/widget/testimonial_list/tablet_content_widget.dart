part of 'testimonial_list_widget.dart';

class _TabletContentWidget extends StatelessWidget {
  const _TabletContentWidget({
    required this.testimonials,
    required this.isVisible,
  });

  final List<TestimonialEntity> testimonials;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.space(factor: 5),
        right: context.space(factor: 5),
        bottom: context.space(),
      ),
      child: Wrap(
        spacing: context.space(),
        runSpacing: context.space(),
        children: testimonials.mapIndexed((index, tech) {
          return _CardItemWidget(testimonial: testimonials[index])
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: 0.3,
                duration: 300.ms,
                delay: (100 + index * 100).ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 100.ms, duration: 300.ms);
        }).toList(),
      ),
    );
  }
}
