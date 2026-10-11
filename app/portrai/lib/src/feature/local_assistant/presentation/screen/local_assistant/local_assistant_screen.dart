import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/presentation/route/local_assistant_module_route.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class LocalAssistantScreen extends StatelessWidget {
  const LocalAssistantScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(LocalAssistantModuleRoute.assistant);
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: appServiceLocator.get<LocalAssistantBloc>(),
    child: const _ScreenContent(),
  );
}

class _ScreenContent extends StatefulWidget {
  const _ScreenContent();

  @override
  State<_ScreenContent> createState() => _LocalAssistantScreenState();
}

class _LocalAssistantScreenState extends State<_ScreenContent> {
  @override
  void initState() {
    super.initState();
    context.bloc.add(const LocalAssistantStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return RouteObserverWidget(
      onResume: () => context.bloc.add(const LocalAssistantInitializedEvent()),
      child: Scaffold(
        appBar: AppBar(title: Text(context.localizations.assistantTitle)),
        body: const SafeArea(child: ContentWidget()),
      ),
    );
  }
}
