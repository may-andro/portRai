import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/route/remote_assistant_module_route.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class RemoteAssistantScreen extends StatelessWidget {
  const RemoteAssistantScreen({super.key});

  static void navigate(BuildContext context) =>
      context.pushScreen(RemoteAssistantModuleRoute.assistant);

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: appServiceLocator.get<RemoteAssistantBloc>(),
    child: const _ScreenContent(),
  );
}

class _ScreenContent extends StatefulWidget {
  const _ScreenContent();

  @override
  State<_ScreenContent> createState() => _RemoteAssistantScreenState();
}

class _RemoteAssistantScreenState extends State<_ScreenContent> {
  @override
  void initState() {
    super.initState();
    context.bloc.add(const RemoteAssistantStartedEvent());
  }

  @override
  Widget build(BuildContext context) => RouteObserverWidget(
    onResume: () => context.bloc.add(const RemoteAssistantInitializedEvent()),
    child: Scaffold(
      appBar: AppBar(title: Text(context.localizations.remoteAssistantTitle)),
      body: const SafeArea(child: ContentWidget()),
    ),
  );
}
