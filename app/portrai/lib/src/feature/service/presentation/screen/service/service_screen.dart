import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/route/_route.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
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
      create: (context) {
        return appServiceLocator.get<ServiceBloc>();
      },
      child: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: const _ContentWidget(),
            ),
          );
        },
      ),
    );
  }
}

class _ContentWidget extends StatelessWidget {
  const _ContentWidget();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
