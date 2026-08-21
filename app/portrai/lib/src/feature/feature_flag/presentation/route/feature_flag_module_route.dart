import 'package:portrai/src/feature/feature_flag/presentation/feature_flag_screen.dart';
import 'package:portrai/src/route/route.dart';

class FeatureFlagModuleRoute extends ModuleRoute {
  const FeatureFlagModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final FeatureFlagModuleRoute featureFlag =
      FeatureFlagModuleRoute._(
        name: 'feature_flag',
        path: '/feature-flag',
        builder: (_, _, _) => const FeatureFlagScreen(),
      );
}
