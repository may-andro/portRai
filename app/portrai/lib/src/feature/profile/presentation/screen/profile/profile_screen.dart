import 'package:flutter/material.dart';
import 'package:portrai/src/feature/profile/presentation/route/_route.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ProfileModuleRoute.profile);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<ProfileBloc, ProfileState>(
      onCreate: (bloc) => bloc.add(const LoadProfileEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
