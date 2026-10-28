import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/route/_route.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class ScheduleAppointmentScreen extends StatelessWidget {
  const ScheduleAppointmentScreen({super.key});

  static const topicQueryParameter = 'topic';

  /// Opens the screen with [topic] filled in, when given.
  static void navigate(BuildContext context, {String? topic}) {
    context.pushScreen(
      ScheduleAppointmentModuleRoute.scheduleAppointment,
      queryParameters: {
        if (topic != null && topic.isNotEmpty) topicQueryParameter: topic,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = context.routeQueryParameters[topicQueryParameter] ?? '';
    return ScreenScaffoldWidget<
      ScheduleAppointmentBloc,
      ScheduleAppointmentState
    >(
      onCreate: (bloc) => bloc.add(const LoadAppointmentSlotsEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      listenWhen: (previous, current) =>
          previous.sendFailure != current.sendFailure &&
          current.sendFailure != null,
      listener: (context, state) {
        if (state.sendFailure case final failure?) {
          context.showSnackBar(
            snackBar: DSSnackBar(
              message: FailureTranslator.translate(context, failure),
              type: DSSnackBarType.error,
            ),
          );
        }
      },
      body: ContentWidget(topic: topic),
    );
  }
}
