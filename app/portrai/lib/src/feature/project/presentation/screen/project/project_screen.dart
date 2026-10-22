import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/route/_route.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

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
    return ScreenScaffoldWidget<ProjectBloc, ProjectState>(
      onCreate: (bloc) => bloc.add(LoadProjectEvent(project)),
      onResume: (bloc) => bloc.add(ScreenVisibleEvent()),
      body: const SafeArea(child: ContentWidget()),
    );
  }
}
