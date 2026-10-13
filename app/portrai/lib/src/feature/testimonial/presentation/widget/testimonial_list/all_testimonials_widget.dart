part of 'testimonial_list_widget.dart';

class _AllTestimonialsWidget extends StatelessWidget {
  const _AllTestimonialsWidget({required this.testimonials});

  final List<TestimonialEntity> testimonials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            context.space(factor: 2),
            _hoverLift,
            context.space(factor: 2),
            _shadowRoom,
          ),
          itemCount: testimonials.length + 1,
          separatorBuilder: (_, _) => SizedBox(height: context.space()),
          itemBuilder: (context, index) {
            if (index == 0) {
              return DSTextWidget(
                context.localizations.portfolioSectionTestimonials,
                style: context.typography.emphasizedHeadlineSmall,
                color: context.colorPalette.neutral.grey10,
              );
            }
            return _CardItemWidget(testimonial: testimonials[index - 1]);
          },
        ),
      ),
    );
  }
}
