import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

class DSBulletPointListWidget extends StatelessWidget {
  const DSBulletPointListWidget({super.key, required this.bulletPoints});

  final List<String> bulletPoints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      mainAxisSize: MainAxisSize.min,
      children: bulletPoints.bulletPointWidgets,
    );
  }
}

class _BulletPointWidget extends StatelessWidget {
  const _BulletPointWidget({required this.bulletPoint});

  final String bulletPoint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSTextWidget(
          '•  ',
          color: context.colorPalette.neutral.grey8,
          style: context.typography.bodyMedium,
        ),
        Expanded(
          child: DSTextWidget(
            bulletPoint,
            color: context.colorPalette.neutral.grey8,
            style: context.typography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

extension on List<String> {
  List<Widget> get bulletPointWidgets {
    return map(
      (bulletPoint) => _BulletPointWidget(bulletPoint: bulletPoint),
    ).toList();
  }
}
