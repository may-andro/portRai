import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/extension/l10n_extension.dart';
import 'package:portrai/src/feature/locale/locale.dart';

class LanguageCardWidget extends StatelessWidget {
  const LanguageCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      backgroundColor: context.colorPalette.inverseSurface,
      radius: context.dimen.radiusLevel2,
      elevation: context.dimen.elevationLevel1,
      margin: EdgeInsets.only(bottom: context.space(factor: 2)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
        ),
        leading: Icon(
          Icons.language,
          size: context.iconSize,
          color: context.colorPalette.neutral.grey1.color,
        ),
        title: DSTextWidget(
          context.localizations.selectedLanguage,
          color: context.colorPalette.neutral.grey1,
          style: context.typography.titleMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: DSTextWidget(
          context.languageCode.languageName,
          color: context.colorPalette.neutral.grey3,
          style: context.typography.bodyMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.edit,
          size: context.iconSize,
          color: context.colorPalette.neutral.grey3.color,
        ),
        onTap: () => LocaleSelectionScreen.navigate(context),
      ),
    );
  }
}
