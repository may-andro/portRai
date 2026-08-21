import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/setting/setting.dart';

part 'header_desktop_content_widget.dart';

part 'header_mobile_tablet_content_widget.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    required this.sections,
    required this.tabController,
    super.key,
  });

  static double getHeight(BuildContext context) {
    return context.contentHeight;
  }

  final List<SectionWidget> sections;

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.colorPalette.background.color,
      surfaceTintColor: context.colorPalette.neutral.transparent.color,
      shadowColor: context.colorPalette.background.color,
      toolbarHeight: getHeight(context),
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: DSResponsiveContainerWidget(
          mobileBuilder: (_) => const _HeaderMobileTabletContentWidget(),
          tabletBuilder: (_) => const _HeaderMobileTabletContentWidget(),
          desktopBuilder: (_) => _HeaderDesktopContentWidget(
            sections: sections,
            tabController: tabController,
          ),
        ),
      ),
    );
  }
}

extension on BuildContext {
  double get contentHeight {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return _HeaderMobileTabletContentWidget.getHeight(this);
      case DSDeviceResolution.tablet:
        return _HeaderMobileTabletContentWidget.getHeight(this);
      case DSDeviceResolution.desktop:
        return _HeaderDesktopContentWidget.getHeight(this);
    }
  }
}
