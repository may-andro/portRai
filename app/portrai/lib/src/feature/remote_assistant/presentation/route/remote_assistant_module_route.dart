import 'package:portrai/src/feature/remote_assistant/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class RemoteAssistantModuleRoute extends ModuleRoute {
  RemoteAssistantModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final RemoteAssistantModuleRoute assistant =
      RemoteAssistantModuleRoute._(
        name: 'remote_assistant',
        path: '/remote-assistant',
        builder: (_, _, _) => const RemoteAssistantScreen(),
      );
}
