import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/_bloc.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/widget/_widget.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ScreenScaffoldWidget<OnboardingBloc, OnboardingState>(
        onCreate: (bloc) => bloc.add(const OnboardingStartedEvent()),
        listenWhen: (previous, current) =>
            previous.isCompleted != current.isCompleted ||
            previous.failure != current.failure,
        listener: (context, state) {
          if (state.isCompleted) {
            context.goScreen(PortfolioModuleRoute.portfolio);
            return;
          }
          if (state.failure case final failure?) {
            context.showSnackBar(
              snackBar: DSSnackBar(
                message: FailureTranslator.translate(context, failure),
                type: DSSnackBarType.error,
              ),
            );
          }
        },
        body: const ContentWidget(),
      );
}
