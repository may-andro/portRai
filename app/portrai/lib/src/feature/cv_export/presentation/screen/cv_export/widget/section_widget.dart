part of 'content_widget.dart';

/// A titled group of controls with an optional hint.
class _SectionWidget extends StatelessWidget {
  const _SectionWidget({required this.title, required this.child, this.hint});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;

    return Padding(
      padding: EdgeInsets.only(bottom: context.space(factor: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSTextWidget(
            title,
            style: context.typography.titleMedium,
            color: palette.neutral.grey9,
          ),
          if (hint case final hint?)
            DSTextWidget(
              hint,
              style: context.typography.bodySmall,
              color: palette.neutral.grey7,
            ),
          SizedBox(height: context.space()),
          child,
        ],
      ),
    );
  }
}
