part of 'professional_summary_widget.dart';

class _ElevatorPitchWidget extends StatelessWidget {
  const _ElevatorPitchWidget({
    required this.label,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final String label;
  final bool hasHorizontalPadding;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          DSTextWidget(
                label,
                style: context.typography.emphasizedTitleMedium,
                color: context.colorPalette.neutral.grey8,
                isItalic: true,
              )
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: -0.3,
                end: 0,
                duration: 300.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, delay: 100.ms),
    );
  }
}
