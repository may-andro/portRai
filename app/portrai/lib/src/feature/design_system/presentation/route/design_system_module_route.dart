import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/design_system_gallery_screen.dart';
import 'package:portrai/src/route/route.dart';

class DesignSystemModuleRoute extends ModuleRoute {
  const DesignSystemModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final DesignSystemModuleRoute designSystemGallery =
      DesignSystemModuleRoute._(
        name: 'design_system_gallery',
        path: '/themes',
        builder: (_, _, _) => const DesignSystemGalleryScreen(),
      );
}
