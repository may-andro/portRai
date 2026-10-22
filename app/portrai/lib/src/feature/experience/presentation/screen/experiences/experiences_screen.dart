import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/presentation/route/_route.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class ExperiencesScreen extends StatelessWidget {
  const ExperiencesScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ExperienceModuleRoute.experiences);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<ExperiencesBloc, ExperiencesState>(
      onCreate: (bloc) => bloc.add(const LoadExperiencesEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
