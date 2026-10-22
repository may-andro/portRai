import 'package:flutter/material.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/route/remote_assistant_module_route.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/app_bar_widget.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/widget/content_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class RemoteAssistantScreen extends StatelessWidget {
  const RemoteAssistantScreen({super.key});

  static void navigate(BuildContext context) =>
      context.pushScreen(RemoteAssistantModuleRoute.assistant);

  @override
  Widget build(BuildContext context) =>
      ScreenScaffoldWidget<RemoteAssistantBloc, RemoteAssistantState>(
        isRetained: true,
        onResume: (bloc) => bloc.add(const RemoteAssistantStartedEvent()),
        appBar: const AppBarWidget(),
        body: const SafeArea(child: ContentWidget()),
      );
}
