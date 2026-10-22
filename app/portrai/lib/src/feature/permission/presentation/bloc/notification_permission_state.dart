import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';
import 'package:use_case/use_case.dart';

class NotificationPermissionState extends Equatable {
  const NotificationPermissionState({this.status, this.failure});

  /// The system's notification permission for the app; null until read.
  final AppPermissionStatus? status;
  final Failure? failure;

  bool get isAllowed => status?.isGranted ?? false;

  @override
  List<Object?> get props => [status, failure];
}
