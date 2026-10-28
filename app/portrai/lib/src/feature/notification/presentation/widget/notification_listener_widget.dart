import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/job_opening.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/feature/schedule_appointment/schedule_appointment.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

/// Keeps notifications in step with the app while it runs, opens the screen
/// a tapped notification is about, and shows the notifications that arrive
/// while the app is in the foreground. Does nothing on the web.
class NotificationListenerWidget extends StatefulWidget {
  const NotificationListenerWidget({required this.child, super.key});

  final Widget child;

  @override
  State<NotificationListenerWidget> createState() =>
      _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget>
    with WidgetsBindingObserver {
  // The router may not have built its first page when the app is opened from
  // a notification, so opening waits for it for at most this many frames.
  static const _maxFramesToWaitForNavigator = 30;

  NotificationListenerBloc? _bloc;
  StreamSubscription<NotificationListenerState>? _blocSubscription;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    WidgetsBinding.instance.addObserver(this);
    final bloc = appServiceLocator.get<NotificationListenerBloc>();
    _bloc = bloc;
    _blocSubscription = bloc.stream.listen(_onState);
    bloc.add(
      NotificationListenerStartEvent(
        AppLocalizations.supportedLocales
            .map((locale) => locale.languageCode)
            .toList(),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // The permission may have changed, in the system prompt or the device
    // settings.
    if (state == AppLifecycleState.resumed) {
      _bloc?.add(const NotificationsSyncRequestedEvent());
    }
  }

  void _onState(NotificationListenerState state) {
    switch (state) {
      case PushMessageOpenedState(:final message):
        _open(message.kind);
      case PushMessageReceivedState(:final message):
        _show(message);
      case NotificationListenerIdleState():
        break;
    }
  }

  void _open(PushMessageKind kind, {int frame = 0}) {
    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) {
      if (frame < _maxFramesToWaitForNavigator) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _open(kind, frame: frame + 1),
        );
      }
      return;
    }
    switch (kind) {
      case PushMessageKind.jobOpenings:
        // The route asks for sign-in first when nobody is signed in.
        navigatorContext.pushScreen(JobOpeningModuleRoute.jobOpenings);
      case PushMessageKind.appointmentRequest:
        navigatorContext.pushScreen(
          ScheduleAppointmentModuleRoute.appointmentRequests,
        );
      case PushMessageKind.portfolioUpdate:
        navigatorContext.goScreen(PortfolioModuleRoute.portfolio);
      case PushMessageKind.unknown:
        break;
    }
  }

  void _show(PushMessageEntity message) {
    final navigatorContext = rootNavigatorKey.currentContext;
    final text = [message.title, message.body].whereType<String>().join(' · ');
    if (navigatorContext == null || text.isEmpty) return;
    navigatorContext.showSnackBar(snackBar: DSSnackBar(message: text));
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
      _blocSubscription?.cancel();
      _bloc?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
