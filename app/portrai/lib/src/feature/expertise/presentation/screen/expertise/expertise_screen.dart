import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/route/_route.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

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
    return ScreenScaffoldWidget<ExpertiseBloc, ExpertiseState>(
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: ContentWidget(expertise: expertise),
    );
  }
}
