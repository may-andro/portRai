import 'package:portrai/src/feature/experience/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ExperienceModuleRoute extends ModuleRoute {
  ExperienceModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
    super.children = const [],
  });

  static final ExperienceModuleRoute experience = ExperienceModuleRoute._(
    name: 'experience',
    path: '/experience/:${ExperienceScreen.routePathParameter}',
    builder: (_, extra, _) {
      return ExperienceScreen(id: extra as String);
    },
  );

  static final ExperienceModuleRoute experiences = ExperienceModuleRoute._(
    name: 'experiences',
    path: '/experiences',
    builder: (_, _, _) {
      return const ExperiencesScreen();
    },
    children: [experience],
  );
}
