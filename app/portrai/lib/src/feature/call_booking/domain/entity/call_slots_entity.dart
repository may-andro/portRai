import 'package:equatable/equatable.dart';

/// The times a visitor can book a call at.
class CallSlotsEntity extends Equatable {
  const CallSlotsEntity({
    required this.slots,
    required this.slotDuration,
    required this.ownerTimeZone,
  });

  /// The start of each free slot in UTC, earliest first.
  final List<DateTime> slots;
  final Duration slotDuration;

  /// The owner's IANA time zone, such as `Europe/Madrid`.
  final String ownerTimeZone;

  @override
  List<Object?> get props => [slots, slotDuration, ownerTimeZone];
}
