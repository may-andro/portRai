import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

class DSResponsiveContainerWidget extends StatelessWidget {
  const DSResponsiveContainerWidget({
    required this.mobileBuilder,
    required this.tabletBuilder,
    required this.desktopBuilder,
    super.key,
  });

  final WidgetBuilder mobileBuilder;
  final WidgetBuilder tabletBuilder;
  final WidgetBuilder desktopBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (context.deviceResolution) {
          case DSDeviceResolution.mobile:
            return mobileBuilder(context);
          case DSDeviceResolution.tablet:
            return tabletBuilder(context);
          case DSDeviceResolution.desktop:
            return desktopBuilder(context);
        }
      },
    );
  }
}

class DSResponsiveWidthContainerWidget extends StatelessWidget {
  const DSResponsiveWidthContainerWidget({
    required this.xsBuilder,
    required this.sBuilder,
    required this.mBuilder,
    required this.lBuilder,
    required this.xlBuilder,
    super.key,
  });

  final WidgetBuilder xsBuilder;
  final WidgetBuilder sBuilder;
  final WidgetBuilder mBuilder;
  final WidgetBuilder lBuilder;
  final WidgetBuilder xlBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (context.deviceWidth) {
          case DSDeviceWidthResolution.xs:
            return xsBuilder(context);
          case DSDeviceWidthResolution.s:
            return sBuilder(context);
          case DSDeviceWidthResolution.m:
            return mBuilder(context);
          case DSDeviceWidthResolution.l:
            return lBuilder(context);
          case DSDeviceWidthResolution.xl:
            return xlBuilder(context);
        }
      },
    );
  }
}
