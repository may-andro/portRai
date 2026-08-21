import 'package:equatable/equatable.dart';

class WorkingHoursEntity extends Equatable {
  const WorkingHoursEntity({
    required this.timezone,
    required this.preferredHours,
    required this.weekdays,
    required this.weekends,
  });

  final String timezone;
  final String preferredHours;
  final bool weekdays;
  final String weekends;

  @override
  List<Object?> get props => [timezone, preferredHours, weekdays, weekends];
}
