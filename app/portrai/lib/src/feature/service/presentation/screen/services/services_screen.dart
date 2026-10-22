import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/presentation/route/_route.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ServiceModuleRoute.services);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<ServicesBloc, ServicesState>(
      onCreate: (bloc) => bloc.add(const LoadServicesEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      backgroundColor: context.colorPalette.surface.inverseSurface,
      body: const ContentWidget(),
    );
  }
}
