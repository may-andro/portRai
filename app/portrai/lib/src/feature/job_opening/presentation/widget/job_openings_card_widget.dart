import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';
import 'package:portrai/src/route/route.dart';

/// The Settings entry point. Opening it asks for sign-in first when needed.
class JobOpeningsCardWidget extends StatelessWidget {
  const JobOpeningsCardWidget({super.key, this.onOpen});

  /// Called when the job openings are opened, before they are shown, so the
  /// host screen can track the tap.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return DSCardWidget(
      backgroundColor: palette.inverseSurface,
      radius: context.dimen.radiusLevel2,
      elevation: context.dimen.elevationLevel1,
      margin: EdgeInsets.only(bottom: context.space(factor: 2)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
        ),
        leading: Icon(
          Icons.work_outline,
          size: context.iconSize,
          color: palette.neutral.grey1.color,
        ),
        title: DSTextWidget(
          context.localizations.jobOpeningsCardTitle,
          color: palette.neutral.grey1,
          style: context.typography.titleMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: DSTextWidget(
          context.localizations.jobOpeningsCardDescription,
          color: palette.neutral.grey3,
          style: context.typography.bodyMedium,
          maxLines: 2,
          textOverflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: context.iconSize,
          color: palette.neutral.grey3.color,
        ),
        onTap: () {
          onOpen?.call();
          context.pushScreen(JobOpeningModuleRoute.jobOpenings);
        },
      ),
    );
  }
}
