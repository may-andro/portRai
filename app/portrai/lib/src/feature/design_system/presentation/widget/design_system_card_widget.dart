import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/design_system/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/design_system/presentation/route/_route.dart';
import 'package:portrai/src/route/route.dart';

/// The Settings entry point to the theme gallery, naming the theme in use.
class DesignSystemCardWidget extends StatelessWidget {
  const DesignSystemCardWidget({super.key});

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
          Icons.palette_outlined,
          size: context.iconSize,
          color: palette.neutral.grey1.color,
        ),
        title: DSTextWidget(
          context.localizations.themeCardTitle,
          color: palette.neutral.grey1,
          style: context.typography.titleMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: DSTextWidget(
          context.theme.designSystem.title(context),
          color: palette.neutral.grey3,
          style: context.typography.bodyMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: context.iconSize,
          color: palette.neutral.grey3.color,
        ),
        onTap: () =>
            context.pushScreen(DesignSystemModuleRoute.designSystemGallery),
      ),
    );
  }
}
