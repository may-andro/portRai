import 'package:core/core.dart';

class PortraiAppConfigEntity extends AppConfig {
  const PortraiAppConfigEntity({required this.minimumRequiredAppVersion});

  factory PortraiAppConfigEntity.fromJson(Map<String, dynamic> json) {
    return PortraiAppConfigEntity(
      minimumRequiredAppVersion: json['minimumRequiredAppVersion'] as String,
    );
  }

  final String minimumRequiredAppVersion;

  Map<String, dynamic> toJson() {
    return {'minimumRequiredAppVersion': minimumRequiredAppVersion};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortraiAppConfigEntity &&
          runtimeType == other.runtimeType &&
          minimumRequiredAppVersion == other.minimumRequiredAppVersion;

  @override
  int get hashCode => minimumRequiredAppVersion.hashCode;

  @override
  String toString() =>
      'PortraiAppConfigEntity(minimumRequiredAppVersion: $minimumRequiredAppVersion)';
}
