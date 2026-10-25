import 'package:json_annotation/json_annotation.dart';

part 'notification_device_model.g.dart';

/// A `users/{uid}/devices/{token}` document, without its server-set
/// `updatedAt`.
@JsonSerializable(createFactory: false)
class NotificationDeviceModel {
  NotificationDeviceModel({required this.locale, required this.platform});

  /// The app's language, such as `es`.
  final String locale;

  /// `android`, `ios` or `web`.
  final String platform;

  Map<String, dynamic> toJson() => _$NotificationDeviceModelToJson(this);
}
