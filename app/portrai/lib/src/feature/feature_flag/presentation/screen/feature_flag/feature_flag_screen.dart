import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/presentation/route/_route.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class FeatureFlagScreen extends StatelessWidget {
  const FeatureFlagScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(FeatureFlagModuleRoute.featureFlag);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<FeatureFlagBloc, FeatureFlagState>(
      onCreate: (bloc) => bloc.add(const LoadFeatureFlagEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
