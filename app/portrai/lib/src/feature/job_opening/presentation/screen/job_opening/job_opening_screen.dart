import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/widget/_widget.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class JobOpeningScreen extends StatelessWidget {
  const JobOpeningScreen({super.key, required this.id});

  static const routePathParameter = 'id';

  final String id;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<JobOpeningBloc, JobOpeningState>(
      onCreate: (bloc) => bloc.add(JobOpeningStartedEvent(id: id)),
      listenWhen: (previous, current) =>
          previous.applyFailure != current.applyFailure &&
          current.applyFailure != null,
      listener: (context, state) => context.showSnackBar(
        snackBar: DSSnackBar(
          message: FailureTranslator.translate(context, state.applyFailure!),
          type: DSSnackBarType.error,
        ),
      ),
      body: const ContentWidget(),
    );
  }
}
