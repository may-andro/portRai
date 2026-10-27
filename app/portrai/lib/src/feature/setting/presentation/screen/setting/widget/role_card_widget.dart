import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:portrai/src/route/route.dart';

class RoleCardWidget extends StatelessWidget {
  const RoleCardWidget({super.key, required this.role});

  final UserRole role;

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
          Icons.badge_outlined,
          size: context.iconSize,
          color: context.colorPalette.neutral.grey1.color,
        ),
        title: DSTextWidget(
          context.localizations.settingChangeRole,
          color: context.colorPalette.neutral.grey1,
          style: context.typography.titleMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: DSTextWidget(
          role.title(context),
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
        onTap: () {
          context.bloc.add(const SettingEntryClickEvent('role'));
          context.goScreen(OnboardingModuleRoute.onboarding);
        },
      ),
    );
  }
}
