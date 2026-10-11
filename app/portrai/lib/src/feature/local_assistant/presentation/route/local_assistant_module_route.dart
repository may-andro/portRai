import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
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
        builder: (_, _, _) => BlocProvider.value(
          value: appServiceLocator.get<LocalAssistantBloc>(),
          child: const LocalAssistantScreen(),
        ),
      );
}
