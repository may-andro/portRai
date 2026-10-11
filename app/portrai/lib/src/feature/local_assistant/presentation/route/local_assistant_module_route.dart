import 'package:portrai/src/feature/local_assistant/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class LocalAssistantModuleRoute extends ModuleRoute {
  LocalAssistantModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final LocalAssistantModuleRoute assistant =
      LocalAssistantModuleRoute._(
        name: 'assistant',
        path: '/assistant',
        builder: (_, _, _) => const LocalAssistantScreen(),
      );
}
