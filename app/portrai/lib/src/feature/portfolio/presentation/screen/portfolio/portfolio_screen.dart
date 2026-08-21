import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<PortfolioBloc>()
          ..add(const LoadPortfolioEvent());
      },
      child: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(const ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              drawer: context.isDesktop ? null : const DrawerWidget(),
              drawerEnableOpenDragGesture: false,
              onDrawerChanged: (isOpened) {
                context.bloc.add(DrawerClickEvent(isOpened));
              },
              body: const ContentWidget(),
            ),
          );
        },
      ),
    );
  }
}
