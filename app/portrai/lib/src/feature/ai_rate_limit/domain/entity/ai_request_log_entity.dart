import 'package:equatable/equatable.dart';

/// When this install sent its recent Firebase AI requests.
class AiRequestLogEntity extends Equatable {
  const AiRequestLogEntity({this.requestTimes = const []});

  final List<DateTime> requestTimes;

  @override
  List<Object?> get props => [requestTimes];
}
