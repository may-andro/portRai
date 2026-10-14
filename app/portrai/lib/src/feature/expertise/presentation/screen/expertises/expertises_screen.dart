import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/presentation/route/_route.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ExpertisesScreen extends StatelessWidget {
  const ExpertisesScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ExpertiseModuleRoute.expertises);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ExpertisesBloc>()
          ..add(const LoadExpertisesEvent());
      },
      child: Builder(
        builder: (context) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(const ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: const ContentWidget(),
            ),
          );
        },
      ),
    );
  }
}
