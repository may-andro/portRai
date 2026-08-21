import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/presentation/route/_route.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ServiceModuleRoute.services);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ServicesBloc>();
      },
      child: BlocBuilder<ServicesBloc, ServicesState>(
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
