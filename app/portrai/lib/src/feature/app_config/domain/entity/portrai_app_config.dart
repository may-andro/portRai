import 'package:core/core.dart';

class PortraiAppConfig extends AppConfig {
  const PortraiAppConfig({required this.minimumRequiredAppVersion});

  factory PortraiAppConfig.fromJson(Map<String, dynamic> json) {
    return PortraiAppConfig(
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
      other is PortraiAppConfig &&
          runtimeType == other.runtimeType &&
          minimumRequiredAppVersion == other.minimumRequiredAppVersion;

  @override
  int get hashCode => minimumRequiredAppVersion.hashCode;

  @override
  String toString() =>
      'PortraiAppConfig(minimumRequiredAppVersion: $minimumRequiredAppVersion)';
}
