import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'image_widget.dart';

part 'card_widget.dart';

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({
    super.key,
    required this.services,
    required this.isVisible,
  });

  final List<ServiceEntity> services;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return DSResponsiveContainerWidget(
      mobileBuilder: (_) {
        return _MobileContentWidget(services: services, isVisible: isVisible);
      },
      tabletBuilder: (_) {
        return _TabletContentWidget(services: services, isVisible: isVisible);
      },
      desktopBuilder: (_) {
        return _DesktopContentWidget(services: services, isVisible: isVisible);
      },
    );
  }
}
