import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/route/_route.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

/// The Settings entry point. Opening it asks for sign-in first when needed.
class AppointmentRequestsCardWidget extends StatelessWidget {
  const AppointmentRequestsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => appServiceLocator.get<AppointmentRequestsCardBloc>(),
      child: const _CardWidget(),
    );
  }
}

/// Tracks the tap and opens the appointment requests.
class _CardWidget extends StatelessWidget {
  const _CardWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return DSCardWidget(
      backgroundColor: palette.inverseSurface,
      radius: context.dimen.radiusLevel2,
      elevation: context.dimen.elevationLevel1,
      margin: EdgeInsets.only(bottom: context.space(factor: 2)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
        ),
        leading: Icon(
          Icons.event_available_outlined,
          size: context.iconSize,
          color: palette.neutral.grey1.color,
        ),
        title: DSTextWidget(
          context.localizations.appointmentRequestsCardTitle,
          color: palette.neutral.grey1,
          style: context.typography.titleMedium,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: DSTextWidget(
          context.localizations.appointmentRequestsCardDescription,
          color: palette.neutral.grey3,
          style: context.typography.bodyMedium,
          maxLines: 2,
          textOverflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: context.iconSize,
          color: palette.neutral.grey3.color,
        ),
        onTap: () {
          context.bloc.add(
            const AppointmentRequestsCardClickEvent(
              'appointment_requests_card',
            ),
          );
          context.pushScreen(
            ScheduleAppointmentModuleRoute.appointmentRequests,
          );
        },
      ),
    );
  }
}
