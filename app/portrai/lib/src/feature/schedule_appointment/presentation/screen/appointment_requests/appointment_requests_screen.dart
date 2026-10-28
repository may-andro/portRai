import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/widget/_widget.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

/// The owner's appointment requests, to accept or decline.
class AppointmentRequestsScreen extends StatelessWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<
      AppointmentRequestsBloc,
      AppointmentRequestsState
    >(
      onCreate: (bloc) => bloc.add(const AppointmentRequestsStartedEvent()),
      listenWhen: (previous, current) =>
          current is LoadedState &&
          current.actionFailure != null &&
          (previous is! LoadedState ||
              previous.actionFailure != current.actionFailure),
      listener: (context, state) {
        if (state case LoadedState(actionFailure: final failure?)) {
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
}
