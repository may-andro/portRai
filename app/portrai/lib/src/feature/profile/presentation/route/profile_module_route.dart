import 'package:portrai/src/feature/profile/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ProfileModuleRoute extends ModuleRoute {
  ProfileModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final ProfileModuleRoute profile = ProfileModuleRoute._(
    name: 'profile',
    path: '/profile',
    builder: (_, extra, _) {
      return const ProfileScreen();
    },
  );
}
