import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/route/_route.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key, required this.service});

  final ServiceEntity service;

  static String get routePathParameter => 'serviceId';

  static void navigate(BuildContext context, {required ServiceEntity service}) {
    context.pushScreen(
      ServiceModuleRoute.service,
      extra: service,
      pathParameters: {routePathParameter: service.title.replaceAll(' ', '_')},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => appServiceLocator.get<ServiceBloc>(),
      child: Builder(
        builder: (context) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: SafeArea(child: ContentWidget(service: service)),
            ),
          );
        },
      ),
    );
  }
}
