part of 'content_widget.dart';

class _ListWidget extends StatelessWidget {
  const _ListWidget({required this.flags});

  final List<AppFeatureFlagEntity> flags;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: flags.map((flag) => _ListItemWidget(flag: flag)).toList(),
    );
  }
}
