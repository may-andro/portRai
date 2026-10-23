import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:portrai/l10n/l10n.dart';

extension DesignSystemNameExtension on DesignSystem {
  /// The festival name shown for this design system.
  String title(BuildContext context) {
    final localizations = context.localizations;
    return switch (this) {
      DesignSystem.beltane => localizations.themeNameBeltane,
      DesignSystem.carnival => localizations.themeNameCarnival,
      DesignSystem.chuseok => localizations.themeNameChuseok,
      DesignSystem.diwali => localizations.themeNameDiwali,
      DesignSystem.halloween => localizations.themeNameHalloween,
      DesignSystem.hogeras => localizations.themeNameHogeras,
      DesignSystem.hogmanay => localizations.themeNameHogmanay,
      DesignSystem.holi => localizations.themeNameHoli,
      DesignSystem.obon => localizations.themeNameObon,
      DesignSystem.pachamama => localizations.themeNamePachamama,
      DesignSystem.sakura => localizations.themeNameSakura,
      DesignSystem.xmas => localizations.themeNameXmas,
    };
  }

  /// A short line describing the look of this design system.
  String tagline(BuildContext context) {
    final localizations = context.localizations;
    return switch (this) {
      DesignSystem.beltane => localizations.themeTaglineBeltane,
      DesignSystem.carnival => localizations.themeTaglineCarnival,
      DesignSystem.chuseok => localizations.themeTaglineChuseok,
      DesignSystem.diwali => localizations.themeTaglineDiwali,
      DesignSystem.halloween => localizations.themeTaglineHalloween,
      DesignSystem.hogeras => localizations.themeTaglineHogeras,
      DesignSystem.hogmanay => localizations.themeTaglineHogmanay,
      DesignSystem.holi => localizations.themeTaglineHoli,
      DesignSystem.obon => localizations.themeTaglineObon,
      DesignSystem.pachamama => localizations.themeTaglinePachamama,
      DesignSystem.sakura => localizations.themeTaglineSakura,
      DesignSystem.xmas => localizations.themeTaglineXmas,
    };
  }
}
