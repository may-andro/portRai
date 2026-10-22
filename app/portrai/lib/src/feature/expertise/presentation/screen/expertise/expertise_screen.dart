import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/route/_route.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ExpertiseScreen extends StatelessWidget {
  const ExpertiseScreen({super.key, required this.expertise});

  final ExpertiseEntity expertise;

  static String get routePathParameter => 'expertiseTitle';

  static void navigate(
    BuildContext context, {
    required ExpertiseEntity expertise,
  }) {
    context.pushScreen(
      ExpertiseModuleRoute.expertiseDetail,
      extra: expertise,
      pathParameters: {routePathParameter: expertise.title},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => appServiceLocator.get<ExpertiseBloc>(),
      child: Builder(
        builder: (context) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(const ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: SafeArea(child: ContentWidget(expertise: expertise)),
            ),
          );
        },
      ),
    );
  }
}
