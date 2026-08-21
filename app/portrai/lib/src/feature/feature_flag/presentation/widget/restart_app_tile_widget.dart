import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/restart_app.dart';

class RestartAppTileWidget extends StatelessWidget {
  const RestartAppTileWidget({
    required this.hasManipulatedFlags,
    super.key,
  });

  final bool hasManipulatedFlags;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Row(
        children: <Widget>[
          Icon(
            Icons.restart_alt_rounded,
            size: context.getTextHeight(context.typography.labelMedium, 1),
          ),
          const DSHorizontalSpacerWidget(0.5),
          Expanded(
            child: DSTextWidget(
              'Restart may be required to apply changes',
              color: context.colorPalette.neutral.grey9,
              style: context.typography.labelMedium,
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
          const DSHorizontalSpacerWidget(2),
          DSButtonWidget(
            label: 'Restart',
            size: DSButtonSize.small,
            variant: DSButtonVariant.text,
            onPressed: () async {
              await restartApp();
            },
          ),
        ],
      ),
      secondChild: const SizedBox.shrink(),
      crossFadeState: hasManipulatedFlags
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 300),
    );
  }
}
