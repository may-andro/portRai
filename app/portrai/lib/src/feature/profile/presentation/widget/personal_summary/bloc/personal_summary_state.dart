import 'package:equatable/equatable.dart';

/// The personal summary shows the profile it is given, so its bloc only
/// handles taps and keeps no state of its own.
final class PersonalSummaryState extends Equatable {
  const PersonalSummaryState();

  @override
  List<Object?> get props => [];
}
