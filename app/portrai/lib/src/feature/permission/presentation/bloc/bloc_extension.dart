import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/notification_permission_bloc.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/notification_permission_state.dart';

extension ContextExtension on BuildContext {
  NotificationPermissionBloc get bloc => read<NotificationPermissionBloc>();

  NotificationPermissionState get state => bloc.state;
}
