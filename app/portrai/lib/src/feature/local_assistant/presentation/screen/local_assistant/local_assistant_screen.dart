import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/presentation/route/local_assistant_module_route.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/widget/content_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';

class LocalAssistantScreen extends StatefulWidget {
  const LocalAssistantScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(LocalAssistantModuleRoute.assistant);
  }

  @override
  State<LocalAssistantScreen> createState() => _LocalAssistantScreenState();
}

class _LocalAssistantScreenState extends State<LocalAssistantScreen> {
  @override
  void initState() {
    super.initState();
    context.bloc.add(const LocalAssistantStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.localizations.assistantTitle)),
      body: const SafeArea(child: ContentWidget()),
    );
  }
}
