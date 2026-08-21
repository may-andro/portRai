part of 'content_widget.dart';

class _AppBarWidget extends StatelessWidget {
  const _AppBarWidget({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: context.colorPalette.background.color,
      surfaceTintColor: context.colorPalette.neutral.transparent.color,
      shadowColor: context.colorPalette.brand.tertiary.color,
      automaticallyImplyLeading: !kIsWeb,
      centerTitle: true,
      title: DSTextWidget(
        title,
        color: context.colorPalette.neutral.grey9,
        style: context.typography.emphasizedTitleMedium,
      ),
    );
  }
}
