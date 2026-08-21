import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/presentation/route/_route.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key, required this.id});

  final String id;

  static String get routePathParameter => 'experienceId';

  static void navigate(BuildContext context, {required String id}) {
    context.pushScreen(
      ExperienceModuleRoute.experience,
      extra: id,
      pathParameters: {routePathParameter: id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ExperienceBloc>()
          ..add(LoadExperienceEvent(id));
      },
      child: BlocBuilder<ExperienceBloc, ExperienceState>(
        builder: (context, state) {
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
