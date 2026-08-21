import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/widget/feature_flag_item_widget.dart';

class FeatureFlagListWidget extends StatelessWidget {
  const FeatureFlagListWidget({super.key, required this.flags});

  final List<AppFeatureFlagEntity> flags;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: flags.map((flag) => FeatureFlagItemWidget(flag: flag)).toList(),
    );
  }
}
