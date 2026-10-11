import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/route/remote_assistant_module_route.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/content_widget.dart';
import 'package:portrai/src/route/route.dart';

class RemoteAssistantScreen extends StatefulWidget {
  const RemoteAssistantScreen({super.key});

  static void navigate(BuildContext context) =>
      context.pushScreen(RemoteAssistantModuleRoute.assistant);

  @override
  State<RemoteAssistantScreen> createState() => _RemoteAssistantScreenState();
}

class _RemoteAssistantScreenState extends State<RemoteAssistantScreen> {
  @override
  void initState() {
    super.initState();
    context.bloc.add(const RemoteAssistantStartedEvent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.localizations.remoteAssistantTitle)),
    body: const SafeArea(child: ContentWidget()),
  );
}
