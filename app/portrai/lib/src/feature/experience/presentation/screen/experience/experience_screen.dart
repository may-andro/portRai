import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/presentation/route/_route.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key, required this.id});

  final String id;

  static String get routePathParameter => 'experienceId';

  static void navigate(BuildContext context, {required String id}) {
    context.pushScreen(
      ExperienceModuleRoute.experience,
      extra: id,
      pathParameters: {routePathParameter: id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<ExperienceBloc, ExperienceState>(
      onCreate: (bloc) => bloc.add(LoadExperienceEvent(id)),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
