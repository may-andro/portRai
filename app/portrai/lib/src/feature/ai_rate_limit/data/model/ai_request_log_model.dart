import 'package:json_annotation/json_annotation.dart';

part 'ai_request_log_model.g.dart';

@JsonSerializable()
class AiRequestLogModel {
  const AiRequestLogModel({required this.requestTimesInMilliseconds});

  factory AiRequestLogModel.fromJson(Map<String, dynamic> json) =>
      _$AiRequestLogModelFromJson(json);

  /// Milliseconds since epoch.
  final List<int> requestTimesInMilliseconds;

  Map<String, dynamic> toJson() => _$AiRequestLogModelToJson(this);
}
