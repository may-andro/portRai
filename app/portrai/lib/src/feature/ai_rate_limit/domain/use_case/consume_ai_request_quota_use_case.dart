import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/exception/_exception.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/repository/_repository.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:use_case/use_case.dart';

sealed class ConsumeAiRequestQuotaFailure extends BasicFailure {
  const ConsumeAiRequestQuotaFailure({super.cause});
}

/// The install used up its per-minute or per-day Firebase AI budget.
class AiRequestQuotaExceededFailure extends ConsumeAiRequestQuotaFailure {
  const AiRequestQuotaExceededFailure({super.cause});
}

class AiRequestQuotaCacheFailure extends ConsumeAiRequestQuotaFailure {
  const AiRequestQuotaCacheFailure({super.cause});
}

class AiRequestQuotaUnknownFailure extends ConsumeAiRequestQuotaFailure {
  const AiRequestQuotaUnknownFailure({super.cause});
}

/// Reserves one Firebase AI request from this install's budget, sized by the
/// app config's `aiRateLimit`. Call it right before a billable request, never
/// for an answer served from cache. Best-effort: cleared app data or a
/// changed device clock resets it, so the backend quota stays the real guard.
@register
class ConsumeAiRequestQuotaUseCase
    extends BaseNoParamUseCase<void, ConsumeAiRequestQuotaFailure> {
  ConsumeAiRequestQuotaUseCase(this._aiRequestLogRepository, this._appConfig);

  static const defaultMaxRequestsPerMinute = 10;
  static const defaultMaxRequestsPerDay = 100;

  final AiRequestLogRepository _aiRequestLogRepository;
  final PortraiAppConfigEntity _appConfig;

  @protected
  @override
  FutureOr<Either<ConsumeAiRequestQuotaFailure, void>> execute() async {
    final now = DateTime.now();
    final aiRateLimit = _appConfig.aiRateLimit;
    final limits = [
      (
        maxRequests: _maxRequests(
          aiRateLimit.maxRequestsPerMinute,
          defaultMaxRequestsPerMinute,
        ),
        window: const Duration(minutes: 1),
      ),
      (
        maxRequests: _maxRequests(
          aiRateLimit.maxRequestsPerDay,
          defaultMaxRequestsPerDay,
        ),
        window: const Duration(days: 1),
      ),
    ];

    final aiRequestLog = await _aiRequestLogRepository.getAiRequestLog();
    // Times ahead of the clock still count, so moving it back gains nothing.
    final recentRequestTimes = [
      for (final requestTime in aiRequestLog.requestTimes)
        if (now.difference(requestTime).abs() < const Duration(days: 1))
          requestTime,
    ];
    for (final limit in limits) {
      final requestCountInWindow = recentRequestTimes
          .where((requestTime) => now.difference(requestTime) < limit.window)
          .length;
      if (requestCountInWindow >= limit.maxRequests) {
        return const Left(AiRequestQuotaExceededFailure());
      }
    }

    await _aiRequestLogRepository.cacheAiRequestLog(
      AiRequestLogEntity(requestTimes: [...recentRequestTimes, now]),
    );
    return const Right(null);
  }

  /// Missing or negative values use [defaultMaxRequests]; 0 is kept, so the
  /// app config can switch Firebase AI requests off.
  static int _maxRequests(int? configuredMaxRequests, int defaultMaxRequests) =>
      configuredMaxRequests == null || configuredMaxRequests < 0
      ? defaultMaxRequests
      : configuredMaxRequests;

  @protected
  @override
  ConsumeAiRequestQuotaFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    AiRequestLogCacheException() => AiRequestQuotaCacheFailure(cause: error),
    _ => AiRequestQuotaUnknownFailure(cause: error),
  };
}
