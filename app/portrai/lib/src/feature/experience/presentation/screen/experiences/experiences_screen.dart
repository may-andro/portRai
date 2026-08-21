import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/presentation/route/_route.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ExperiencesScreen extends StatelessWidget {
  const ExperiencesScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ExperienceModuleRoute.experiences);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ExperiencesBloc>()
          ..add(const LoadExperiencesEvent());
      },
      child: BlocBuilder<ExperiencesBloc, ExperiencesState>(
        builder: (context, state) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(const ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: ContentWidget(state: state),
            ),
          );
        },
      ),
    );
  }
}
