import 'package:json_annotation/json_annotation.dart';

part 'appointment_slots_model.g.dart';

/// The free slots as the appointment function returns them.
@JsonSerializable(createToJson: false)
class AppointmentSlotsModel {
  AppointmentSlotsModel({
    required this.slots,
    required this.slotMinutes,
    required this.timeZone,
  });

  factory AppointmentSlotsModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentSlotsModelFromJson(json);

  /// Slot starts as ISO 8601 strings in UTC.
  final List<String> slots;
  final int slotMinutes;
  final String timeZone;
}
