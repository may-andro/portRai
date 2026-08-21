part of 'content_widget.dart';

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    required this.label,
    required this.isDesktop,
    required this.children,
  });

  final String label;
  final bool isDesktop;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.horizontalScreenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 2),
        children: [
          _SectionTitleWidget(label: label, isDesktop: isDesktop),
          ...children,
        ],
      ),
    );
  }
}

class _SectionTitleWidget extends StatelessWidget {
  const _SectionTitleWidget({required this.label, required this.isDesktop});

  final String label;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      label,
      style: isDesktop
          ? context.typography.emphasizedTitleMedium
          : context.typography.emphasizedTitleLarge,
      color: context.colorPalette.neutral.grey10,
    );
  }
}
