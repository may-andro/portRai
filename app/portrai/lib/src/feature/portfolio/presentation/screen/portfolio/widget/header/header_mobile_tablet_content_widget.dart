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
        DSLottieIllustrationWidget(
          illustration: DSLottieIllustration.logo,
          width: getHeight(context),
        ),
        const SettingButtonWidget(),
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
      size: context.portfolioIconButtonSize,
      iconColor: context.colorPalette.surface.onSurface,
      buttonColor: context.colorPalette.neutral.transparent,
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }
}
