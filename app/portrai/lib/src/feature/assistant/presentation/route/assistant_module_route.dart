import 'package:portrai/src/feature/assistant/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class AssistantModuleRoute extends ModuleRoute {
  AssistantModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final AssistantModuleRoute assistant = AssistantModuleRoute._(
    name: 'assistant',
    path: '/assistant',
    builder: (_, _, _) => const AssistantScreen(),
  );
}
