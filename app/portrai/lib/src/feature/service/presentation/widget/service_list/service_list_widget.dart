import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/service_screen.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

part 'service_card_widget.dart';

part 'service_grid_widget.dart';

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({
    super.key,
    required this.services,
    required this.isVisible,
    this.visibleItemsCount,
  });

  final List<ServiceEntity> services;
  final bool isVisible;

  /// Limits how many services are shown; all of them when null.
  final int? visibleItemsCount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => appServiceLocator.get<ServiceListBloc>(),
      child: _GridWidget(
        services: services.take(visibleItemsCount ?? services.length).toList(),
        isVisible: isVisible,
      ),
    );
  }
}
