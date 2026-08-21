part of 'header_widget.dart';

class _HeaderMobileTabletContentWidget extends StatelessWidget {
  const _HeaderMobileTabletContentWidget();

  static double getHeight(BuildContext context) => context.space(factor: 8);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _DrawerMenuWidget(),
        Align(
          child: SizedBox(
            height: getHeight(context),
            child: DSImage.logo(fit: BoxFit.cover),
          ),
        ),
        const _SettingButtonWidget(),
      ],
    );
  }
}

class _DrawerMenuWidget extends StatelessWidget {
  const _DrawerMenuWidget();

  @override
  Widget build(BuildContext context) {
    return DSIconButtonWidget(
      Icons.menu_rounded,
      size: context.buttonSize,
      iconColor: context.colorPalette.surface.onSurface,
      buttonColor: context.colorPalette.neutral.transparent,
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }
}

class _SettingButtonWidget extends StatelessWidget {
  const _SettingButtonWidget();

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
