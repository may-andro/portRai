import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/locale_selection_screen.dart';
import 'package:portrai/src/route/route.dart';

class LocaleModuleRoute extends ModuleRoute {
  const LocaleModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final LocaleModuleRoute localeSelection = LocaleModuleRoute._(
    name: 'localeSelection',
    path: '/locale_selection',
    builder: (_, _, _) => const LocaleSelectionScreen(),
  );
}
