part of 'content_widget.dart';

class _LoadedContentPaddingWidget extends StatelessWidget {
  const _LoadedContentPaddingWidget({required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 2),
        vertical: context.space(factor: context.isDesktop ? 2 : 1),
      ),
      sliver: sliver,
    );
  }
}
