import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

part 'service_card_widget.dart';

part 'service_grid_widget.dart';

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({
    super.key,
    required this.services,
    required this.isVisible,
    this.visibleItemsCount,
    required this.onClicked,
  });

  final List<ServiceEntity> services;
  final bool isVisible;

  /// Limits how many services are shown; all of them when null.
  final int? visibleItemsCount;

  /// Called with the service whose card is tapped. The caller decides what
  /// the tap does, such as opening the service.
  final ValueChanged<ServiceEntity> onClicked;

  @override
  Widget build(BuildContext context) {
    return _GridWidget(
      services: services.take(visibleItemsCount ?? services.length).toList(),
      isVisible: isVisible,
      onClicked: onClicked,
    );
  }
}
