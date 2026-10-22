import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/presentation/route/_route.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class ExpertisesScreen extends StatelessWidget {
  const ExpertisesScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(ExpertiseModuleRoute.expertises);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<ExpertisesBloc, ExpertisesState>(
      onCreate: (bloc) => bloc.add(const LoadExpertisesEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
