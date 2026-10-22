import 'package:flutter/material.dart';
import 'package:portrai/src/feature/local_assistant/presentation/route/local_assistant_module_route.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/widget/app_bar_widget.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/widget/content_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class LocalAssistantScreen extends StatelessWidget {
  const LocalAssistantScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(LocalAssistantModuleRoute.assistant);
  }

  @override
  Widget build(BuildContext context) =>
      ScreenScaffoldWidget<LocalAssistantBloc, LocalAssistantState>(
        isRetained: true,
        onResume: (bloc) => bloc.add(const LocalAssistantStartedEvent()),
        appBar: const AppBarWidget(),
        body: const SafeArea(child: ContentWidget()),
      );
}
