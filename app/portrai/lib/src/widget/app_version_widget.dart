import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({super.key, this.onInverseSurface = false});

  final bool onInverseSurface;

  @override
  Widget build(BuildContext context) {
    final version = appServiceLocator.get<PackageInfo>().version;
    return DSTextWidget(
      context.localizations.version('v$version'),
      style: context.typography.emphasizedLabelSmall,
      color: onInverseSurface
          ? context.colorPalette.onInverseSurface
          : context.colorPalette.onBackground,
      textAlign: TextAlign.center,
    );
  }
}
