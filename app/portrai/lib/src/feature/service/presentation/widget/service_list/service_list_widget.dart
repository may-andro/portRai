import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/service_screen.dart';

part 'service_card_widget.dart';

part 'service_grid_widget.dart';

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({
    super.key,
    required this.services,
    required this.isVisible,
    this.visibleItemsCount,
    this.onOpen,
  });

  final List<ServiceEntity> services;
  final bool isVisible;

  /// Limits how many services are shown; all of them when null.
  final int? visibleItemsCount;

  /// Called when a service is opened, before its screen is shown, so the host
  /// screen can track the tap.
  final ValueChanged<ServiceEntity>? onOpen;

  @override
  Widget build(BuildContext context) {
    return _GridWidget(
      services: services.take(visibleItemsCount ?? services.length).toList(),
      isVisible: isVisible,
      onOpen: onOpen,
    );
  }
}
