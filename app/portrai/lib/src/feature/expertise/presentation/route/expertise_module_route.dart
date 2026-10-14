import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ExpertiseModuleRoute extends ModuleRoute {
  ExpertiseModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
    super.children = const [],
  });

  static final ExpertiseModuleRoute expertiseDetail = ExpertiseModuleRoute._(
    name: 'expertise',
    path: '/expertise/:${ExpertiseScreen.routePathParameter}',
    builder: (_, extra, _) {
      return ExpertiseScreen(expertise: extra as ExpertiseEntity);
    },
  );

  static final ExpertiseModuleRoute expertises = ExpertiseModuleRoute._(
    name: 'expertises',
    path: '/expertises',
    builder: (_, _, _) {
      return const ExpertisesScreen();
    },
    children: [expertiseDetail],
  );
}
