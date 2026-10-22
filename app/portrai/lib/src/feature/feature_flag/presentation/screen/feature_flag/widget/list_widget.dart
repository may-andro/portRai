part of 'content_widget.dart';

class _ListWidget extends StatelessWidget {
  const _ListWidget({required this.flags});

  final List<AppFeatureFlagEntity> flags;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: flags.length,
      itemBuilder: (context, index) => _ListItemWidget(flag: flags[index]),
    );
  }
}
