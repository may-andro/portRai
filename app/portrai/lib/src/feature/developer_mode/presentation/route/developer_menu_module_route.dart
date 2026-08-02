import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/developer_menu_screen.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/feature_flag/feature_flag_screen.dart';
import 'package:portrai/src/route/route.dart';

class DeveloperMenuModuleRoute extends ModuleRoute {
  const DeveloperMenuModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final DeveloperMenuModuleRoute developerMenu =
      DeveloperMenuModuleRoute._(
        name: 'developer_menu',
        path: '/developer-menu',
        builder: (_, _, _) => const DeveloperMenuScreen(),
      );

  static final DeveloperMenuModuleRoute featureFlag =
      DeveloperMenuModuleRoute._(
        name: 'feature_flag',
        path: '/developer-menu/feature-flag',
        builder: (_, _, _) => const FeatureFlagScreen(),
      );
}
