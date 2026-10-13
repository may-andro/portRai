import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_detail/service_detail.dart';

part 'service_card_widget.dart';

part 'service_grid_widget.dart';

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
    return _GridWidget(services: services, isVisible: isVisible);
  }
}
