part of 'professional_summary_widget.dart';

class _ProfileImageWidget extends StatelessWidget {
  const _ProfileImageWidget({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
              offset: Offset(0, context.space(factor: 5)),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorPalette.brand.primary.color,
                      context.colorPalette.brand.primary.color.withAlpha(50),
                    ],
                  ),
                ),
              ),
            )
            .animate(target: isVisible ? 1 : 0)
            .scale(
              begin: Offset.zero,
              end: const Offset(1, 1),
              duration: 300.ms,
              delay: 700.ms,
              curve: Curves.decelerate,
            ),
        Container(
          alignment: Alignment.bottomCenter,
          child: SizedBox(child: DSImage.avatar(fit: BoxFit.cover))
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: 1,
                end: 0,
                duration: 300.ms,
                delay: 500.ms,
                curve: Curves.decelerate,
              )
              .fadeIn(duration: 300.ms, delay: 500.ms),
        ),
      ],
    );
  }
}
