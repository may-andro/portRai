import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/tracking_events_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/tracking_events_state.dart';

extension ContextExtension on BuildContext {
  TrackingEventsBloc get bloc => read<TrackingEventsBloc>();

  TrackingEventsState get state => bloc.state;
}
