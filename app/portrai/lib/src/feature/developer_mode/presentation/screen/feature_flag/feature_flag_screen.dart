import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/developer_mode/presentation/route/developer_menu_module_route.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/feature_flag/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';

class FeatureFlagScreen extends StatelessWidget {
  const FeatureFlagScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(DeveloperMenuModuleRoute.featureFlag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DSAppBarWidget(height: DSAppBarWidget.getHeight(context)),
      body: BlocProvider(
        create: (_) {
          return appServiceLocator.get<FeatureFlagBloc>()
            ..add(const LoadFeatureFlagEvent());
        },
        child: const ContentWidget(),
      ),
    );
  }
}
