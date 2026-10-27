import 'package:flutter/material.dart';
import 'package:portrai/src/feature/developer_mode/presentation/route/_route.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/widget/_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class TrackingEventsScreen extends StatelessWidget {
  const TrackingEventsScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(DeveloperMenuModuleRoute.trackingEvents);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<TrackingEventsBloc, TrackingEventsState>(
      onCreate: (bloc) => bloc.add(const TrackingEventsStartedEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      body: const ContentWidget(),
    );
  }
}
