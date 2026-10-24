import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/notification_listener_bloc.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/notification_listener_state.dart';

extension ContextExtension on BuildContext {
  NotificationListenerBloc get bloc => read<NotificationListenerBloc>();

  NotificationListenerState get state => bloc.state;
}
