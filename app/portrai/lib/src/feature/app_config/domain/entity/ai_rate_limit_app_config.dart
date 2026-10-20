import 'package:equatable/equatable.dart';

/// Remotely managed per-install budget for Firebase AI requests (text and
/// image together); null means default, 0 blocks every request.
class AiRateLimitAppConfig extends Equatable {
  const AiRateLimitAppConfig({
    this.maxRequestsPerMinute,
    this.maxRequestsPerDay,
  });

  final int? maxRequestsPerMinute;
  final int? maxRequestsPerDay;

  @override
  List<Object?> get props => [maxRequestsPerMinute, maxRequestsPerDay];
}
