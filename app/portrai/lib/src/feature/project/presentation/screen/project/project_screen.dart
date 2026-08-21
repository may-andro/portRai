import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/route/_route.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key, required this.project});

  final ProjectEntity project;

  static String get routePathParameter => 'projectId';

  static void navigate(BuildContext context, {required ProjectEntity project}) {
    context.pushScreen(
      ProjectModuleRoute.projectDetail,
      extra: project,
      pathParameters: {routePathParameter: project.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return appServiceLocator.get<ProjectBloc>()
          ..add(LoadProjectEvent(project));
      },
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, _) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: const SafeArea(child: ContentWidget()),
            ),
          );
        },
      ),
    );
  }
}
