import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/presentation/route/assistant_module_route.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/widget/content_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(AssistantModuleRoute.assistant);
  }

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AssistantBloc>().add(const AssistantStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.localizations.assistantTitle)),
      body: const SafeArea(child: ContentWidget()),
    );
  }
}
