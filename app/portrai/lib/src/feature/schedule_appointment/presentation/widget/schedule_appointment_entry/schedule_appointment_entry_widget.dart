import 'package:flutter/material.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/_screen.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

/// A way into scheduling an appointment that hosts style themselves. While scheduling is
/// off it shows [fallback], which is empty unless given.
class ScheduleAppointmentEntryWidget extends StatelessWidget {
  const ScheduleAppointmentEntryWidget({
    super.key,
    required this.trackingLabel,
    required this.builder,
    this.topic,
    this.fallback = const SizedBox.shrink(),
  });

  /// Names the tapped element in tracking, such as `service_schedule_appointment_button`.
  final String trackingLabel;

  /// Builds the entry. Calling `onScheduleAppointment` opens the appointment screen.
  final Widget Function(
    BuildContext context,
    VoidCallback onScheduleAppointment,
  )
  builder;

  /// Filled in as what the appointment is about, such as a service's title.
  final String? topic;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          appServiceLocator.get<ScheduleAppointmentEntryBloc>()
            ..add(const LoadScheduleAppointmentEntryEvent()),
      child:
          BlocBuilder<
            ScheduleAppointmentEntryBloc,
            ScheduleAppointmentEntryState
          >(
            builder: (context, state) {
              if (!state.isAvailable) return fallback;
              return builder(context, () {
                context.bloc.add(
                  ScheduleAppointmentClickEvent(
                    label: trackingLabel,
                    topic: topic,
                  ),
                );
                ScheduleAppointmentScreen.navigate(context, topic: topic);
              });
            },
          ),
    );
  }
}
