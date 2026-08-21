part of 'testimonial_list_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({
    required this.testimonials,
    required this.isVisible,
  });

  final List<TestimonialEntity> testimonials;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.screenHorizontalPadding,
      child: GridView.builder(
        itemCount: testimonials.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: context.space(),
          mainAxisSpacing: context.space(),
          mainAxisExtent: _CardItemWidget.getHeight(context),
        ),
        itemBuilder: (context, index) {
          return _CardItemWidget(testimonial: testimonials[index])
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: 0.3,
                duration: 300.ms,
                delay: (100 + index * 100).ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 100.ms, duration: 300.ms);
        },
      ),
    );
  }
}
