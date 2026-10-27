import 'package:equatable/equatable.dart';

/// The card shows fixed content, so its bloc only handles the tap and keeps
/// no state of its own.
final class JobOpeningsCardState extends Equatable {
  const JobOpeningsCardState();

  @override
  List<Object?> get props => [];
}
