import 'package:json_annotation/json_annotation.dart';

part 'call_slots_model.g.dart';

/// The free slots as the booking function returns them.
@JsonSerializable(createToJson: false)
class CallSlotsModel {
  CallSlotsModel({
    required this.slots,
    required this.slotMinutes,
    required this.timeZone,
  });

  factory CallSlotsModel.fromJson(Map<String, dynamic> json) =>
      _$CallSlotsModelFromJson(json);

  /// Slot starts as ISO 8601 strings in UTC.
  final List<String> slots;
  final int slotMinutes;
  final String timeZone;
}
