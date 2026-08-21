import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/profile/presentation/route/_route.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ProfileModuleRoute.profile);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ProfileBloc>()
          ..add(const LoadProfileEvent());
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(const ScreenVisibleEvent()),
            child: Scaffold(
              backgroundColor: context.colorPalette.background.color,
              body: const ContentWidget(),
            ),
          );
        },
      ),
    );
  }
}
