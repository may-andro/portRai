import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class JobOpeningsScreen extends StatelessWidget {
  const JobOpeningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return appServiceLocator.get<JobOpeningsBloc>()
          ..add(const JobOpeningsStartedEvent());
      },
      child: BlocListener<JobOpeningsBloc, JobOpeningsState>(
        listenWhen: (previous, current) =>
            previous.isSignedOut != current.isSignedOut ||
            previous.actionFailure != current.actionFailure,
        listener: (context, state) {
          if (state.isSignedOut) {
            // The private screens are closed, so leave for the start page.
            context.goLocation('/');
            return;
          }
          if (state.actionFailure case final failure?) {
            context.showSnackBar(
              snackBar: DSSnackBar(
                message: FailureTranslator.translate(context, failure),
                type: DSSnackBarType.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: context.colorPalette.background.color,
          body: const ContentWidget(),
        ),
      ),
    );
  }
}
