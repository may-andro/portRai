import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/setting/setting.dart';

class SettingButtonWidget extends StatelessWidget {
  const SettingButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DSIconButtonWidget(
      Icons.settings,
      size: context.buttonSize,
      iconColor: context.colorPalette.surface.onSurface,
      buttonColor: context.colorPalette.neutral.transparent,
      onPressed: () => SettingScreen.navigate(context),
    );
  }
}

extension on BuildContext {
  DSIconButtonSize get buttonSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return DSIconButtonSize.large;
      case DSDeviceResolution.tablet:
        return DSIconButtonSize.small;
      case DSDeviceResolution.desktop:
        return DSIconButtonSize.small;
    }
  }
}
