import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/extension/_extension.dart';
import 'package:portrai/src/feature/setting/setting.dart';

class SettingButtonWidget extends StatelessWidget {
  const SettingButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DSIconButtonWidget(
      Icons.settings,
      size: context.portfolioIconButtonSize,
      iconColor: context.colorPalette.surface.onSurface,
      buttonColor: context.colorPalette.neutral.transparent,
      onPressed: () => SettingScreen.navigate(context),
    );
  }
}
