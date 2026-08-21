import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ProjectModuleRoute extends ModuleRoute {
  ProjectModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final ProjectModuleRoute projectDetail = ProjectModuleRoute._(
    name: 'project',
    path: '/project/:${ProjectScreen.routePathParameter}',
    builder: (_, extra, params) {
      return ProjectScreen(project: extra as ProjectEntity);
    },
  );
}
