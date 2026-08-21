import 'package:portrai/src/feature/setting/presentation/screen/setting/setting_screen.dart';
import 'package:portrai/src/route/route.dart';

class SettingModuleRoute extends ModuleRoute {
  const SettingModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final SettingModuleRoute setting = SettingModuleRoute._(
    name: 'setting',
    path: '/setting',
    builder: (_, _, _) => const SettingScreen(),
  );
}
