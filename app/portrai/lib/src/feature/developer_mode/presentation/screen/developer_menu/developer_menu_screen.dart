import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/developer_mode/presentation/route/developer_menu_module_route.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';

class DeveloperMenuScreen extends StatelessWidget {
  const DeveloperMenuScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(DeveloperMenuModuleRoute.developerMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DSAppBarWidget(height: DSAppBarWidget.getHeight(context)),
      body: BlocProvider(
        create: (_) {
          return appServiceLocator.get<DeveloperMenuBloc>()
            ..add(const LoadDeveloperMenuEvent());
        },
        child: const ContentWidget(),
      ),
    );
  }
}
