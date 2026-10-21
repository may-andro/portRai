part of 'content_widget.dart';

/// A full-width band with an icon title, revealed when scrolled into view.
class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    required this.title,
    required this.icon,
    required this.child,
    this.isAlternate = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool isAlternate;

  @override
  Widget build(BuildContext context) {
    return JobOpeningRevealWidget(
      child: JobOpeningBandWidget(
        isAlternate: isAlternate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 2.5),
          children: [
            JobOpeningSectionTitleWidget(title: title, icon: icon),
            child,
          ],
        ),
      ),
    );
  }
}
