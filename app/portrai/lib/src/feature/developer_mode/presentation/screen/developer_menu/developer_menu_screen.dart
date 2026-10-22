import 'package:flutter/material.dart';
import 'package:portrai/src/feature/developer_mode/presentation/route/developer_menu_module_route.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/widget/_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class DeveloperMenuScreen extends StatelessWidget {
  const DeveloperMenuScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(DeveloperMenuModuleRoute.developerMenu);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<DeveloperMenuBloc, DeveloperMenuState>(
      onCreate: (bloc) => bloc.add(const LoadDeveloperMenuEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
