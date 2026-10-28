import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

sealed class AppointmentRequestsState extends Equatable {
  const AppointmentRequestsState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends AppointmentRequestsState {
  const LoadingState();
}

final class ErrorState extends AppointmentRequestsState {
  const ErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends AppointmentRequestsState {
  const LoadedState({
    required this.requests,
    this.decidingRequestId,
    this.actionFailure,
  });

  /// Earliest slot first.
  final List<ReceivedAppointmentRequestEntity> requests;

  /// The request whose answer is being saved, so its buttons wait.
  final String? decidingRequestId;

  /// Why an answer could not be saved. Shown once.
  final Failure? actionFailure;

  /// The requests the owner can still answer at [now], earliest first.
  List<ReceivedAppointmentRequestEntity> openRequests(DateTime now) =>
      requests.where((request) => request.isAnswerableAt(now)).toList();

  /// The answered requests and those whose time has come, latest first.
  List<ReceivedAppointmentRequestEntity> closedRequests(DateTime now) =>
      requests.reversed
          .where((request) => !request.isAnswerableAt(now))
          .toList();

  @override
  List<Object?> get props => [requests, decidingRequestId, actionFailure];
}
